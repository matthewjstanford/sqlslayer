IF OBJECT_ID('mon.SQLRestarts_Notification','P') IS NOT NULL 
	DROP PROCEDURE [mon].[SQLRestarts_Notification]
GO

/******************************************************************************
* Name
	[mon].[SQLRestarts_Notification]

* Author
	Adam Bean
	
* Date
	2011.04.20
	
* Synopsis
	Procedure to scan SQL restart data and send notification of data that needs to be updated

*******************************************************************************
* License
*******************************************************************************
	Copyright © SQLSlayer.com. All rights reserved.

	All objects published by SQLSlayer.com are licensed and goverened by 
	Creative Commons Attribution-Share Alike 3.0
	http://creativecommons.org/licenses/by-sa/3.0/

	For more scripts and sample code, go to http://www.SQLSlayer.com

	You may alter this code for your own *non-commercial* purposes. You may
	republish altered code as long as you give due credit.

	THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
	ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
	TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
	PARTICULAR PURPOSE.
*******************************************************************************
* Change History
*******************************************************************************
	Date:		Author:			Description:
	--------	--------		---------------------------------------
	YYYYDDMM	Full Name	
******************************************************************************/

CREATE PROCEDURE [mon].[SQLRestarts_Notification]
(
	@Recipients			VARCHAR(1024)	= NULL
	,@SendEmail			TINYINT			= 1
	,@Debug				BIT				= 0
)

AS

SET NOCOUNT ON 

DECLARE
	@Body				VARCHAR(MAX)
	,@EmailHeader		VARCHAR(2048)
	,@EmailFooter		VARCHAR(2048)
	,@EmailBody			VARCHAR(2048)
	,@Subject			VARCHAR(256)
	,@SPID				INT
	,@SQLID				INT
	,@SQL				VARCHAR(128)
	,@Count				INT
	,@Connections		INT

IF @Debug = 1
	PRINT '/*** DEBUG ENABLED ****/'
	
-- Verify valid @Recipients
IF @Recipients IS NULL AND @Debug = 0
BEGIN
	RAISERROR ('@Recipients must be passed in.',16,1) WITH NOWAIT
	RETURN
END

-- Replace commas with semi-colons to work properly for database mail
SET @Recipients = REPLACE(@Recipients, ',', ';')

-- Build email
-- Setup table to build body
DECLARE @BodyContents TABLE 
(
	[html]			VARCHAR(MAX)
)

-- Setup table to build email
DECLARE @Email TABLE 
(
	[ID]			INT IDENTITY
	,[html]			VARCHAR(MAX)
)

-- Set subject
SET @Subject = 'Recent SQL restarts requiring information'

-- Build the email header
SELECT @EmailHeader = 
'
<HTML>
<DIV ALIGN="CENTER">
<TABLE BORDER="5" CELLSPACING="5" CELLPADDING="5" ALIGN="CENTER">
<CAPTION>
	<H2>Production SQL instances restarted in the last 30 days that have not yet been commented on.</H2>
	<p>Fill in @DBAComments appropriately with any notes about the incident.
	<br>
	Set @Type = 1 if expected, 0 (default) if unexpected.</p>
	<EM>The data can be queried through the [' + DB_NAME() +'].[hist].[SQLRestarts_vw] view.</EM>
</CAPTION>
<TR BGCOLOR="#C0C0C0">
	<TH>Server Name</TH>
	<TH>Time Of Restart</TH>
	<TH>Outage Duration (S)</TH>
	<TH>TSQL command</TH>
</TR>
'

-- Build the email footer
SELECT @EmailFooter =
'
</DIV>
</TABLE>
<P ALIGN="CENTER"><FONT SIZE="1">
Message sent from ' + @@SERVERNAME + ' via SQL Server Agent @ ' + CAST(GETDATE() AS VARCHAR(24)) + '.<br>
</P>
</FONT>
</HTML>
'

-- Build the email body
INSERT INTO @BodyContents
SELECT '
		<TR>
			<TD>' + [ServerName] + '</TD>
			<TD>' + CAST([TimeOfRestart] AS VARCHAR) + '</TD>
			<TD>' + CAST([OutageInSeconds] AS VARCHAR) + '</TD>
			<TD>' + 'EXEC [' + DB_NAME() +'].[hist].[SQLRestarts_UpdateValue] @SQLRestartID = ' + CAST([SQLRestartHistoryID] AS VARCHAR) + ', @DBAComments = '''', @Type = 0</TD>
		</TR>' AS [html]
FROM [hist].[SQLRestarts_vw]
WHERE DATEADD(DAY,-30,GETDATE()) < [TimeOfRestart]
AND [Environment] = 'PROD'
AND [DBAComments] IS NULL

-- Build the email
INSERT INTO @Email
SELECT @EmailHeader
UNION ALL
SELECT * FROM @BodyContents
UNION ALL
SELECT @EmailFooter

-- Put it all together
SET @Count = 1
SET @Body = ''
WHILE @Count <= (SELECT COUNT(*) FROM @Email)
BEGIN
	SET @Body = @Body + (SELECT [html] FROM @Email WHERE [ID] = @Count)
	SET @Count = @Count + 1
END

-- Only send email if there is data
IF @Count > 3
BEGIN
	IF @Debug = 0
	BEGIN
		-- Send mail using sp_send_dbmail
		EXEC [msdb].[dbo].[sp_send_dbmail]
			@Recipients		= @Recipients
			,@Subject		= @Subject
			,@Body			= @Body
			,@Body_format	= 'HTML'
	END
	ELSE
	BEGIN
		PRINT 'Debug enabled, no email will be sent'
		SELECT 
			*
		FROM [hist].[SQLRestarts_vw]
		WHERE DATEADD(DAY,-30,GETDATE()) < [TimeOfRestart]
		AND [Environment] = 'PROD'
		AND [DBAComments] IS NULL
	END
END

SET NOCOUNT OFF