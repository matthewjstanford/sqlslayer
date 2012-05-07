# Module manifest file for DBACCollector
# 20110120
# Matt Stanford

@{

# Script module or binary module file associated with this manifest
ModuleToProcess = 'module.psm1'

# Version number of this module.
ModuleVersion = '1.0'

# ID used to uniquely identify this module
GUID = 'CD7F5747-1106-43F6-BE92-3B4DD5A9A2F5'

# Author of this module
Author = 'Matt Stanford'

# Company or vendor of this module
CompanyName = 'SQLSlayer'

# Copyright statement for this module
Copyright = '(c) 2011 SQLSlayer. All rights reserved.'

# Description of the functionality provided by this module
Description = 'This module is the core of all DBAC collector modules with centralized functionality.'

# Minimum version of the Windows PowerShell engine required by this module
PowerShellVersion = '2.0'

# Script files (.ps1) that are run in the caller's environment prior to importing this module
ScriptsToProcess = @("Configuration.ps1")

# Functions to export from this module
FunctionsToExport = '*'

# Cmdlets to export from this module
CmdletsToExport = '*'

# Variables to export from this module
VariablesToExport = '*'

# Aliases to export from this module
AliasesToExport = '*'

}