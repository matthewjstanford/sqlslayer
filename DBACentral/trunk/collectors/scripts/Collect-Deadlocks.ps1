param(
	[int]$DaysToProcess = 30,
	[switch]$AllServers,
	[switch]$Verbose,
	[switch]$Debug
)

$local:ErrorActionPreference = "Stop"

Import-Module DBACCollector -Force -Global

if ($Verbose){$VerbosePreference = "Continue"}
if ($Debug){
	$DebugPreference = "Continue"
	$VerbosePreference = "Continue"
	GetConfig
	}

# Input parameter print
Write-Debug "Input parameters: -DaysToProcess = $DaysToProcess"
Log "Starting Script" "Begin" "" $MyInvocation.MyCommand.path

$DBAC = OpenDBAC;

if ($DBAC.State -ne "Open")
{
	$DBAC.Open()
}

Write-Debug "Successfully connected to $DBAC.DataSource"

$TargetServerQuery = @"
SELECT 
	[ServerName]
FROM [dbo].[ServerInventory_SQL_ServerAttributes_vw]
WHERE AttributeName = 'DeadlockInfo_Collect'
AND AttributeValue = 'TRUE'
"@

if ($AllServers) {
$TargetServerQuery = @"
	SELECT 
		[FullName] AS [ServerName]
	FROM [dbo].[ServerInventory_SQL_AllServers_vw]
"@
}

$errorlogquery = @"
DECLARE @DaysToProcess INT

SET @DaysToProcess = $DaysToProcess

IF OBJECT_ID('tempdb.dbo.#el') IS NOT NULL
	DROP TABLE #el
IF OBJECT_ID('tempdb.dbo.#eli') IS NOT NULL
	DROP TABLE #eli

CREATE TABLE #el (
	[Archive]	INT
	,[Date]		DATETIME
	,[Size]		INT
)

CREATE TABLE #eli (
	[id]			INT IDENTITY
	,[LogDate]	DATETIME
	,[ProcessInfo]	VARCHAR(50)
	,[Text]			NVARCHAR(4000)
)

INSERT INTO #el
EXEC sp_enumerrorlogs 1

DECLARE @num INT

DECLARE #e CURSOR LOCAL STATIC FOR 
SELECT Archive FROM #el 
WHERE [Date] >= DATEADD(DAY,-@DaysToProcess,GETDATE())
ORDER BY 1 DESC

OPEN #e
FETCH NEXT FROM #e INTO @num

WHILE @@FETCH_STATUS = 0
BEGIN
	INSERT INTO #eli ([LogDate],[ProcessInfo],[Text])
	EXEC sp_readerrorlog @num
	
	FETCH NEXT FROM #e INTO @num
END
CLOSE #e
DEALLOCATE #e

SELECT [LogDate],[ProcessInfo],[Text] 
FROM #eli
WHERE [LogDate] >= DATEADD(DAY,-@DaysToProcess,GETDATE())
ORDER BY [id]
"@

# Define some functions for later use
function Get-DLVictimInfo ([string]$message) {

	$msg_array = $message.split('=');
	
	return $msg_array[1];

}

function Get-DLProcessResourceInfo([string]$message) {
	$msg = $message.Replace("process id","process-id");
	$msg = $msg.Replace("pagelock","locktype=pagelock");
	$msg = $msg.Replace("keylock","locktype=keylock");
	$msg = $msg.Replace("databaselock","locktype=dblock");
	$msg = $msg.Replace("objectlock","locktype=objectlock");
	$msg = $msg.Replace("owner ","owner=owner ");
	$msg = $msg.Replace("waiter ","waiter=waiter ");
	$msg_array = $msg.split('=');

	$key = ''
	$val = ''
	$ret = @{};

	for ($i = 0; $i -lt $msg_array.Length - 1;  $i++) {
			
		# initial condition
		if ($i -eq 0) {
			# Get Key
			$key = $msg_array[$i]
			
			# Get Value
			$s_val = $msg_array[$i + 1];
			$a_val = $s_val.Split(' ');
			
			if ($a_val.Length -gt 1) {
				$val = $s_val.Replace($a_val[$a_val.Length - 1],'')
			}
		# final condition
		} elseif ($i -eq $msg_array.Length - 2) {
			# Get Key
			$key = $msg_array[$i].Split(' ');
			
			if ($key.Length -gt 1) {
				$key = $key[$key.Length - 1]
			}
			
			# Get Value
			$val = $msg_array[$i + 1];
		# normal conditions (middle of array)
		} elseif ($i -gt 0) {
			# Get Key
			$key = $msg_array[$i].Split(' ');
			
			if ($key.Length -gt 1) {
				$key = $key[$key.Length - 1]
			}

			# Get Value
			$s_val = $msg_array[$i + 1];
			$a_val = $s_val.Split(' ');

			if ($a_val.Length -gt 1) {
				$val = $s_val.Replace($a_val[$a_val.Length - 1],'')
			}
		} 
		
		$ret.Add($key,$val.TrimEnd(' '));
	}
	
	return $ret;
}

$ServerList = GetServerList $DBAC $TargetServerQuery

foreach ($TargetServerRow IN $ServerList) {

	$TargetServer = $TargetServerRow.ServerName

	# Initilize all variables

	$cn_TargetServer = GetStandardSQLConnection $TargetServer

	Log "Successfully Connected & Gathering deadlock information" "Progress" $TargetServer $MyInvocation.MyCommand.path
	
	Write-Debug "Successfully connected to $TargetServer"
	Write-Verbose "gathering data from server ($TargetServer)"
	
	# Get the error log info from the target server
	$dtErrorLog = GetDataTable $cn_TargetServer $errorlogquery;
	
	$cn_TargetServer.Close();
	$cn_TargetServer.Dispose();

	Write-Debug "Successfully queried the target server"

	# This hash holds an ID for each SPID, incremented for that SPID when a "deadlock-list" event occurs
	$spidids = @{}
	$groupedlines = @{}

	write-verbose "sorting deadlock info"

	# Read the raw file, group each deadlock into an array of lines
	foreach ($row in $dtErrorLog) {
		$LogDate = $row.LogDate;
		$spid = $row.ProcessInfo;
		if ($row.Text.GetType() -eq [System.String]) {
			$message = $row.Text.TrimStart(' ');
			
			if ($message.Contains("deadlock-list")) {
			
				# Get/Create the unique id for this SPID
				if ($spidids.Contains($spid)) {
					$i = $spidids[$spid];
					$spidids[$spid] = ++$i;
				} else {
					$spidids.Add($spid,1);
				}
				
				$spidid = $spid + "." + $spidids[$spid];
				
				# Add this SPIDID to the hash
				$groupedlines.Add($spidid,@($row));
			} else {
				# Only add lines that relate to deadlocks
				if ($spidids[$spid] -ne $null) {
			
					$spidid = $spid + "." + $spidids[$spid];
					($groupedlines[$spidid]) += $row;
				}
			}
		}
	}

	$deadlocks = $null
	$deadlocks = @{}

	write-verbose "processing deadlocks"

	# Create and populate the $deadlocks data structure
	foreach ($spidid in $groupedlines.Keys) {

		# Identify if we're in the "resource-list" section of the deadlock
		$isresourcerow = $false;
		$isexecutionstack = $false;

		foreach ($row in $groupedlines[$spidid]) {
			$date = $row.LogDate;
			$spid = $row.ProcessInfo;
			$message = $row.Text.TrimStart(' ');
			
			if ($message.Contains("deadlock-list")) {
				$deadlocks.Add($spidid,@{
										"date" = $date;
										"victim" = ""; 
										"allrows" = $groupedlines[$spidid];
										"processes" = @{}; 
										"resources" = @{};
										"spid" = $spid;
										});
				$processid = $null;
				
			} elseif ($message.Contains('deadlock victim=')) {
				# victim info
				$victim = get-dlvictiminfo $message;
				
				# Add to the hash
				($deadlocks[$spidid])["victim"] = $victim;
			} elseif ($message.Contains('process id')) {
				# process info
				$proccesslist = Get-DLProcessResourceInfo $message;
				$processid = ($proccesslist["process-id"]).TrimEnd(' ')
				
				# Add to the hash
				(($deadlocks[$spidid])["processes"]).Add($processid ,$proccesslist)
				
			} elseif ($message.Contains('executionStack')) {
				$isexecutionstack = $true;
			} elseif ($message.Contains('resource-list')) {
				$isresourcerow = $true;
				$isexecutionstack = $false;
				$resourceid = $null;
			} elseif (($isexecutionstack -eq $true) -and ($processid -ne $null)) {
				# process execution stack
				
				if (((($deadlocks[$spidid])["processes"])[$processid]).Contains('executionStack') -eq $false) {
					((($deadlocks[$spidid])["processes"])[$processid]).Add('executionStack',@());
				}
				
				((($deadlocks[$spidid])["processes"])[$processid])['executionStack'] += $message;
				
			} elseif ($isresourcerow -eq $true) {
				# process resource rows
				if ($message.Contains(' id=lock'))  {
					#$spidid + "`t" + $message;
					$resourcelist = Get-DLProcessResourceInfo $message;
					$resourceid = $resourcelist["id"];
					# Add to the hash
					if (!(($deadlocks[$spidid])["resources"]).Contains($resourceid)) {
						(($deadlocks[$spidid])["resources"]).Add($resourceid ,$resourcelist);
					}
				} elseif ($message.Contains('owner ')) {
					$ownerlist = Get-DLProcessResourceInfo $message;
					if (((($deadlocks[$spidid])["resources"])[$resourceid]).Contains("owners")) {
						((($deadlocks[$spidid])["resources"])[$resourceid])["owners"] += $ownerlist;
					} else {
						((($deadlocks[$spidid])["resources"])[$resourceid]).Add("owners" ,@($ownerlist));
					}
				} elseif ($message.Contains('waiter ')) {
					$waiterlist = Get-DLProcessResourceInfo $message;
					if (((($deadlocks[$spidid])["resources"])[$resourceid]).Contains("waiters")) {
						((($deadlocks[$spidid])["resources"])[$resourceid])["waiters"] += $waiterlist;
					} else {
						((($deadlocks[$spidid])["resources"])[$resourceid]).Add("waiters" ,@($waiterlist));
					}
				}
			}	
		}
	}

	write-verbose "storing deadlocks in DBA server"
	
	try
	{	
		# Process the $deadlocks data structure
		foreach ($spidid in $deadlocks.Keys) {

			if ($DBAC.State -ne "Open")
			{
				$DBAC.Open()
			}

			$Inserter = New-Object System.Data.SqlClient.SqlCommand("[hist].[Deadlock_NewDeadlock_InsertValue]",$DBAC);
			$Inserter.CommandType = "StoredProcedure";
			
			$Inserter.Parameters.Add("@ServerName",$TargetServer) | Out-Null
			$Inserter.Parameters.Add("@DeadlockSPID",($deadlocks[$spidid])["spid"]) | Out-Null
			$Inserter.Parameters.Add("@VictimProcess",($deadlocks[$spidid])["victim"]) | Out-Null
			$Inserter.Parameters.Add("@DeadlockDate",($deadlocks[$spidid])["date"]) | Out-Null
			$Inserter.Parameters.Add("@HistDeadlockID",[System.Data.SqlDbType]"INT") | Out-Null
			$Inserter.Parameters["@HistDeadlockID"].Direction = [System.Data.ParameterDirection]"Output" 
			
			$Inserter.ExecuteNonQuery() | out-null
			$HistDeadlockID = $Inserter.Parameters["@HistDeadlockID"].Value;
			$Inserter.Dispose()
			
			# Add the processes
			
			foreach ($processid in (($deadlocks[$spidid])["processes"]).Keys) {
				$Inserter = New-Object System.Data.SqlClient.SqlCommand("[hist].[Deadlock_ProcessList_InsertValue]",$DBAC);
				$Inserter.CommandType = "StoredProcedure";

				$Inserter.Parameters.Add("@HistDeadlockID",$HistDeadlockID) | Out-Null
				$Inserter.Parameters.Add("@clientapp",((($deadlocks[$spidid])["processes"])[$processid])["clientapp"]) | Out-Null
				$Inserter.Parameters.Add("@currentdb",((($deadlocks[$spidid])["processes"])[$processid])["currentdb"]) | Out-Null
				$Inserter.Parameters.Add("@hostname",((($deadlocks[$spidid])["processes"])[$processid])["hostname"]) | Out-Null
				$Inserter.Parameters.Add("@hostpid",((($deadlocks[$spidid])["processes"])[$processid])["hostpid"]) | Out-Null
				$Inserter.Parameters.Add("@isolationlevel",((($deadlocks[$spidid])["processes"])[$processid])["isolationlevel"]) | Out-Null
				$Inserter.Parameters.Add("@kpid",((($deadlocks[$spidid])["processes"])[$processid])["kpid"]) | Out-Null
				$Inserter.Parameters.Add("@lastbatchstarted",((($deadlocks[$spidid])["processes"])[$processid])["lastbatchstarted"]) | Out-Null
				$Inserter.Parameters.Add("@lastbatchcompleted",((($deadlocks[$spidid])["processes"])[$processid])["lastbatchcompleted"]) | Out-Null
				$Inserter.Parameters.Add("@lasttranstarted",((($deadlocks[$spidid])["processes"])[$processid])["lasttranstarted"]) | Out-Null
				$Inserter.Parameters.Add("@lockmode",((($deadlocks[$spidid])["processes"])[$processid])["lockmode"]) | Out-Null
				$Inserter.Parameters.Add("@loginname",((($deadlocks[$spidid])["processes"])[$processid])["loginname"]) | Out-Null
				$Inserter.Parameters.Add("@priority",((($deadlocks[$spidid])["processes"])[$processid])["priority"]) | Out-Null
				$Inserter.Parameters.Add("@processid",$processid) | Out-Null
				$Inserter.Parameters.Add("@taskpriority",((($deadlocks[$spidid])["processes"])[$processid])["taskpriority"]) | Out-Null
				$Inserter.Parameters.Add("@sbid",((($deadlocks[$spidid])["processes"])[$processid])["sbid"]) | Out-Null
				$Inserter.Parameters.Add("@schedulerid",((($deadlocks[$spidid])["processes"])[$processid])["schedulerid"]) | Out-Null
				$Inserter.Parameters.Add("@spid",((($deadlocks[$spidid])["processes"])[$processid])["spid"]) | Out-Null
				$Inserter.Parameters.Add("@runstatus",((($deadlocks[$spidid])["processes"])[$processid])["status"]) | Out-Null
				$Inserter.Parameters.Add("@transactionname",((($deadlocks[$spidid])["processes"])[$processid])["transactionname"]) | Out-Null
				$Inserter.Parameters.Add("@transcount",((($deadlocks[$spidid])["processes"])[$processid])["transcount"]) | Out-Null
				$Inserter.Parameters.Add("@waitresource",((($deadlocks[$spidid])["processes"])[$processid])["waitresource"]) | Out-Null
				$Inserter.Parameters.Add("@waittime",((($deadlocks[$spidid])["processes"])[$processid])["waittime"]) | Out-Null

				$Inserter.ExecuteNonQuery() | Out-Null
				$Inserter.Dispose()
				
				# Add the execution stack for each process
				for ($i = 0; $i -lt (((($deadlocks[$spidid])["processes"])[$processid])["executionStack"]).Length - 1; $i++) {
					$stack = (((($deadlocks[$spidid])["processes"])[$processid])["executionStack"])[$i]
					
					$Inserter = New-Object System.Data.SqlClient.SqlCommand("[hist].[Deadlock_Process_ExecutionStack_InsertValue]",$DBAC);
					$Inserter.CommandType = "StoredProcedure";
					
					$Inserter.Parameters.Add("@HistDeadlockID",$HistDeadlockID) | Out-Null
					$Inserter.Parameters.Add("@processid",$processid) | Out-Null
					$Inserter.Parameters.Add("@Stack",$stack) | Out-Null
					$Inserter.Parameters.Add("@sequence",$i) | Out-Null

					$Inserter.ExecuteNonQuery() | Out-Null
					$Inserter.Dispose()
				}

			}
			
			# Add the resources
			
			foreach ($resourceid in (($deadlocks[$spidid])["resources"]).Keys) {
				$Inserter = New-Object System.Data.SqlClient.SqlCommand("[hist].[Deadlock_ResourceList_InsertValue]",$DBAC);
				$Inserter.CommandType = "StoredProcedure";
				
				$Inserter.Parameters.Add("@HistDeadlockID",$HistDeadlockID) | Out-Null
				$Inserter.Parameters.Add("@id",$resourceid) | Out-Null
				$Inserter.Parameters.Add("@indexname",((($deadlocks[$spidid])["resources"])[$resourceid])["indexname"]) | Out-Null
				$Inserter.Parameters.Add("@hobtid",((($deadlocks[$spidid])["resources"])[$resourceid])["hobtid"]) | Out-Null
				$Inserter.Parameters.Add("@locktype",((($deadlocks[$spidid])["resources"])[$resourceid])["locktype"]) | Out-Null
				$Inserter.Parameters.Add("@mode",((($deadlocks[$spidid])["resources"])[$resourceid])["mode"]) | Out-Null
				$Inserter.Parameters.Add("@associatedObjectID",((($deadlocks[$spidid])["resources"])[$resourceid])["associatedObjectID"]) | Out-Null
				$Inserter.Parameters.Add("@dbid",((($deadlocks[$spidid])["resources"])[$resourceid])["dbid"]) | Out-Null
				$Inserter.Parameters.Add("@fileid",((($deadlocks[$spidid])["resources"])[$resourceid])["fileid"]) | Out-Null
				$Inserter.Parameters.Add("@pageid",((($deadlocks[$spidid])["resources"])[$resourceid])["pageid"]) | Out-Null
				
				if (((($deadlocks[$spidid])["resources"])[$resourceid])["locktype"] -eq 'dblock') {
					$Inserter.Parameters.Add("@objectname",((($deadlocks[$spidid])["resources"])[$resourceid])["dbname"]) | Out-Null
				} else {
					$Inserter.Parameters.Add("@objectname",((($deadlocks[$spidid])["resources"])[$resourceid])["objectname"]) | Out-Null
				} 
				
				$Inserter.ExecuteNonQuery() | Out-Null
				$Inserter.Dispose()
				
				# Now add owner and waiter information for this resource
				# -- Owner --
				foreach ($owner in ((($deadlocks[$spidid])["resources"])[$resourceid])["owners"]) {
					$Inserter = New-Object System.Data.SqlClient.SqlCommand("[hist].[Deadlock_ResourceOwner_InsertValue]",$DBAC);
					$Inserter.CommandType = "StoredProcedure";

					$Inserter.Parameters.Add("@HistDeadlockID",$HistDeadlockID) | Out-Null
					$Inserter.Parameters.Add("@ResourceID",$resourceid) | Out-Null
					$Inserter.Parameters.Add("@ProcessID",$owner["id"]) | Out-Null
					$Inserter.Parameters.Add("@mode",$owner["mode"]) | Out-Null

					$Inserter.ExecuteNonQuery() | Out-Null
					$Inserter.Dispose()
				}
				
				# -- Waiter --
				foreach ($waiter in ((($deadlocks[$spidid])["resources"])[$resourceid])["waiters"]) {
					$Inserter = New-Object System.Data.SqlClient.SqlCommand("[hist].[Deadlock_ResourceWaiter_InsertValue]",$DBAC);
					$Inserter.CommandType = "StoredProcedure";

					$Inserter.Parameters.Add("@HistDeadlockID",$HistDeadlockID) | Out-Null
					$Inserter.Parameters.Add("@ResourceID",$resourceid) | Out-Null
					$Inserter.Parameters.Add("@ProcessID",$waiter["id"]) | Out-Null
					$Inserter.Parameters.Add("@mode",$waiter["mode"]) | Out-Null
					$Inserter.Parameters.Add("@requestType",$waiter["requestType"]) | Out-Null

					$Inserter.ExecuteNonQuery() | Out-Null
					$Inserter.Dispose()
				}
			}
		}
	}
	catch
	{	
		Log "$error[0].ToString()" "Error" $ServerName $MyInvocation.MyCommand.path
	}
	
	write-verbose "done"
	Log "Done Processing for this server" "Progress" $TargetServer $MyInvocation.MyCommand.path
}
Log "Script execution complete" "End" "" $MyInvocation.MyCommand.path