$local:ErrorActionPreference = "Stop"

function Log {
	param(
		[string]$message,
		[string]$State,
		[string]$ServerName,
		[string]$ScriptName
	)
	
	$__Logger_Rev = "1"
	$__Logger_UserName = $env:username
	
	# Limit the size of the message
	if ($message.length -gt 500)
	{
		$message = $message.Substring(0,500)
	}
	
    # Make sure the connection is open
	$c = OpenDBAC;
    
    $Logger_Conn = New-Object System.Data.SqlClient.SqlCommand("[hist].[Collectors_Log_InsertValue]",$c);
	$Logger_Conn.CommandType = "StoredProcedure";

	$Logger_Conn.Parameters.Add("@ServerName",$ServerName) | Out-Null
    $Logger_Conn.Parameters.Add("@LoginName",$__Logger_UserName) | Out-Null
    $Logger_Conn.Parameters.Add("@ScriptName",$ScriptName) | Out-Null
    $Logger_Conn.Parameters.Add("@State",$State) | Out-Null
    $Logger_Conn.Parameters.Add("@LogMessage",$message) | Out-Null
    $Logger_Conn.Parameters.Add("@LogVersion",$__Logger_Rev) | Out-Null
	$Logger_Conn.Parameters.Add("@RetentionDays",$__Global_LogRetentionDays) | Out-Null
	$Logger_Conn.ExecuteNonQuery() | out-null
	$Logger_Conn.Dispose()
}


function OpenDBAC {

	# If the object has been set at some point try to give her the old "open" command
	if ($__Global_DBAC_Conn -ne $null) {
		if ($__Global_DBAC_Conn.State -ne "Open")
		{
			$__Global_DBAC_Conn.Open()
		}
	} else {

		# Looks like this is the inital setup, so kick it
		$ConString = new-object System.Data.SqlClient.SqlConnectionStringBuilder
		
		$ConString["Data Source"] = $__Global_DBAC_Server;
		$ConString["Initial Catalog"] = $__Global_DBAC_DB_Name;
		$ConString["Application Name"] = "DBAC Collector Module"
		
		if ($__Global_DBAC_User -eq $null) {
			$ConString["Integrated Security"] = $true;
		} else {
			$ConString["UserID"] = $__Global_DBAC_UserID;
			$ConString["Password"] = $__Global_DBAC_Pass;
		}

		$__Global_DBAC_Conn = New-Object System.Data.SqlClient.SqlConnection($ConString.ConnectionString);
		
		$__Global_DBAC_Conn.Open()
	}
	
	return $__Global_DBAC_Conn

}

<# 
 .Synopsis
  Returns a generic SQL Connection for connecting to target servers

 .Description
  Will create a standard SQL connection to run queries against.  This is the base of 
  the DBAC collector set.  This function only works with integrated security.

 .Parameter ServerName
  The ServerName to connect to

 .Parameter AppName
  The "Application Name" that is reported to each SQL Server that is connected.
  If a script name is passed in, the script name will be appended to the app name.
  Defaults to "DBAC Collector Module"

 .Example
   # Basic connection
   $dbac = GetStandardSQLConnection "MyTargetServer"

 .Example
   # Connecting with the script name attached
   $dbac = GetStandardSQLConnection "MyTargetServer" $MyInvocation.MyCommand.path
#>
function GetStandardSQLConnection {
param(
	[string]$ServerName,
	[string]$AppName = "DBAC Collector Module"
)

	if ($AppName.Contains("\"))
	{
		$ScriptName = GetJustScriptName $AppName
		$AppName = "DBAC Collector for $AppName"
	}

	$ConString = new-object System.Data.SqlClient.SqlConnectionStringBuilder
		
	$ConString["Data Source"] = $ServerName;
	$ConString["Initial Catalog"] = "master";
	$ConString["Application Name"] = $AppName	
	$ConString["Integrated Security"] = $true;

	$Conn = New-Object System.Data.SqlClient.SqlConnection($ConString.ConnectionString);
		
	$Conn.Open()
	
	return $Conn

}

function GetJustScriptName {
param(
	[string]$FullName
)
	$ScriptName = $FullName.Substring($FullName.LastIndexOf("\") + 1)
	return $ScriptName
}

function GetServerList {
param(
	[System.Data.SqlClient.SqlConnection]$DBACConn,
	[string]$query
)

	Return GetDataTable $DBACConn $query
}

function GetDataTable {
param(
	[System.Data.SqlClient.SqlConnection]$Conn,
	[string]$query
)
	
	try 
	{
		$ServerName = $Conn.DataSource
		
		if ($Conn.State -ne "Open")
		{
			$Conn.Open();
		}

		$ds_ServerList = New-Object System.Data.DataSet "dsServerList"

		$da_ServerList = New-Object System.Data.SqlClient.SqlDataAdapter ($query,$Conn);
		$da_ServerList.Fill($ds_ServerList) | Out-Null;

		$dtServerList = New-Object System.Data.DataTable "dtServerList";
		$dtServerList = $ds_ServerList.Tables[0];

		Return $dtServerList;
	}
	catch
	{	
		Log "Error executing query: $query" "Error" $ServerName $MyInvocation.MyCommand.path
	}

}

function GetConfig {
	"__Global_DBAC_Server:`t" + $__Global_DBAC_Server
	"__Global_DBAC_DB_Name:`t" + $__Global_DBAC_DB_Name
	"__Global_DBAC_User:`t" + $__Global_DBAC_User
	"__Global_DBAC_Pass:`t" + $__Global_DBAC_Pass
	"__Global_ErrorLog:`t" + $__Global_ErrorLog
}