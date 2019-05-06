
Function Invoke-BatchJob()
{
<#

.SYNOPSIS
    A Powershell script that launches a batch command shell as `SYSTEM` using a run once scheduled task.

.DESCRIPTION
    Shell commands are written to a stdin file at which point the cmd shell will sleep for a period, read the lines from the input file, execute them one at a time and redirect output to a stdout file where it can be retrieved.

.PARAMETER Path
    Path to write batch command shell out to.

.PARAMETER InFile
    Path of command input file to use.

.PARAMETER TaskName
    Name to use for the run-once scheduled task.

.EXAMPLE
    Invoke-BatchJob -Path "C:\Windows\Temp\cmd.bat" -InputFile "C:\Windows\Temp\TMP486.tmp" -TaskName "WindowsUpdateTask"

.LINK
    https://github.com/Spacecow99/Invoke-BatchJob

.NOTES
    Script must be run with Administrator privileges in order to create scheduled task as 'NT AUTHORITY\SYSTEM'.

#>
    Param(
        [Parameter(Mandatory=$True, Position=0)]
        [String] $Path,

        [Parameter(Mandatory=$True, Position=1)]
        [String] $InputFile,
        
        [Parameter(Mandatory=$True, Position=2)]
        [String] $TaskName
    )

    # Char array of Base64 encoded command shell script
    [Char[]] $EncodedPayload = @(
        81, 71, 86, 106, 97, 71, 56, 103, 98, 50, 90, 109, 68, 81, 112, 84, 82, 86, 81, 103, 89, 50, 49, 107,
        88, 51, 66, 104, 100, 71, 103, 57, 73, 110, 115, 119, 102, 83, 73, 78, 67, 109, 78, 118, 99, 72, 107, 103,
        84, 108, 86, 77, 73, 67, 86, 106, 98, 87, 82, 102, 99, 71, 70, 48, 97, 67, 85, 78, 67, 106, 112, 115, 
        98, 50, 57, 119, 68, 81, 112, 119, 97, 87, 53, 110, 73, 67, 49, 117, 73, 68, 69, 103, 77, 83, 52, 120, 
        76, 106, 69, 117, 77, 83, 65, 43, 73, 71, 53, 49, 98, 65, 48, 75, 90, 109, 57, 121, 73, 67, 57, 109, 
        73, 67, 74, 48, 98, 50, 116, 108, 98, 110, 77, 57, 75, 105, 73, 103, 74, 83, 86, 104, 73, 71, 108, 117, 
        73, 67, 103, 108, 89, 50, 49, 107, 88, 51, 66, 104, 100, 71, 103, 108, 75, 83, 66, 107, 98, 121, 65, 111, 
        68, 81, 111, 103, 73, 67, 65, 103, 97, 87, 89, 103, 73, 105, 85, 108, 89, 83, 73, 103, 90, 88, 70, 49,
        73, 67, 74, 107, 97, 87, 85, 105, 73, 67, 103, 78, 67, 105, 65, 103, 73, 67, 65, 103, 73, 67, 65, 103, 
        99, 109, 86, 116, 73, 71, 82, 108, 98, 67, 65, 118, 89, 83, 65, 108, 89, 50, 49, 107, 88, 51, 66, 104, 
        100, 71, 103, 108, 68, 81, 111, 103, 73, 67, 65, 103, 73, 67, 65, 103, 73, 72, 74, 108, 98, 83, 66, 107, 
        90, 87, 119, 103, 76, 50, 69, 103, 74, 87, 78, 116, 90, 70, 57, 119, 89, 88, 82, 111, 74, 83, 53, 121, 
        90, 88, 81, 78, 67, 105, 65, 103, 73, 67, 65, 103, 73, 67, 65, 103, 90, 87, 78, 111, 98, 121, 66, 107, 
        97, 87, 85, 103, 80, 106, 52, 103, 74, 87, 78, 116, 90, 70, 57, 119, 89, 88, 82, 111, 74, 83, 53, 121, 
        90, 88, 81, 78, 67, 105, 65, 103, 73, 67, 65, 103, 73, 67, 65, 103, 90, 50, 57, 48, 98, 121, 66, 108, 
        98, 109, 81, 78, 67, 105, 65, 103, 73, 67, 65, 112, 73, 71, 86, 115, 99, 50, 85, 103, 75, 65, 48, 75, 
        73, 67, 65, 103, 73, 67, 65, 103, 73, 67, 66, 108, 89, 50, 104, 118, 73, 67, 85, 108, 89, 83, 65, 43, 
        80, 105, 65, 108, 89, 50, 49, 107, 88, 51, 66, 104, 100, 71, 103, 108, 76, 110, 74, 108, 100, 65, 48, 75, 
        73, 67, 65, 103, 73, 67, 65, 103, 73, 67, 65, 108, 74, 87, 69, 103, 80, 106, 52, 103, 74, 87, 78, 116, 
        90, 70, 57, 119, 89, 88, 82, 111, 74, 83, 53, 121, 90, 88, 81, 103, 77, 106, 52, 109, 77, 81, 48, 75, 
        73, 67, 65, 103, 73, 67, 65, 103, 73, 67, 66, 108, 89, 50, 104, 118, 73, 67, 48, 116, 76, 83, 48, 116, 
        76, 83, 48, 116, 76, 83, 48, 116, 76, 83, 48, 116, 76, 83, 48, 116, 76, 83, 48, 116, 76, 83, 48, 116, 
        76, 83, 48, 116, 76, 83, 48, 116, 76, 83, 48, 116, 76, 83, 48, 116, 76, 83, 48, 116, 76, 83, 48, 116, 
        76, 83, 48, 116, 76, 83, 48, 116, 76, 83, 48, 116, 76, 83, 48, 116, 76, 83, 48, 116, 73, 68, 52, 43, 
        73, 67, 86, 106, 98, 87, 82, 102, 99, 71, 70, 48, 97, 67, 85, 117, 99, 109, 86, 48, 68, 81, 111, 103, 
        73, 67, 65, 103, 75, 81, 48, 75, 75, 81, 48, 75, 89, 50, 57, 119, 101, 83, 66, 79, 86, 85, 119, 103, 
        74, 87, 78, 116, 90, 70, 57, 119, 89, 88, 82, 111, 74, 81, 48, 75, 90, 50, 57, 48, 98, 121, 66, 115, 
        98, 50, 57, 119
    )

    If (([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
    {
        # Decode and write payload to disk
        [String] $Payload = ([System.Text.Encoding]::ASCII.GetString(([Convert]::FromBase64CharArray($EncodedPayload, 0, $EncodedPayload.Length))) -f $InputFile)
        Set-Content -Path $Path -Value $Payload -Force -ErrorAction 'Stop'

        # Connect to Schedule.Service COM Object
        $ScheduledService = New-Object -ComObject "Schedule.Service"
        $ScheduledService.Connect()

        # Define Scheduled Task
        $TaskDefinition = $ScheduledService.NewTask(0)
        $TaskDefinition.Settings.Hidden = $True
        $TaskDefinition.Settings.StartWhenAvailable = $True
        $TaskDefinition.Principal.UserId = "S-1-5-18"
        $TaskDefinition.Principal.RunLevel = 1
        $Trigger = $TaskDefinition.Triggers.Create(7)
        $Trigger.Id = "TriggerID"
        $Action = $TaskDefinition.Actions.Create(0)
        $Action.Path = ('"{0}"' -f $Path)

        # Register scheduled task in "\" path
        $RootFolder = $ScheduledService.GetFolder("\")
        $RootFolder.RegisterTaskDefinition($TaskName, $TaskDefinition, 6, $Null, $Null, 3)
    }
    Else
    {
        Throw [UnauthorizedAccessException]::New('Operation requires administrative priviledges.')
    }
}


Function Remove-BatchJob()
{
<#

.SYNOPSIS
    Clean-up a BatchJob instance after it has been run.

.DESCRIPTION
    Delete the batch script, input file, output file and the scheduled task.

.PARAMETER Path
    Path to batch command shell to delete.

.PARAMETER InFile
    Path of command input file to delete.

.PARAMETER TaskName
    Name of the scheduled task to delete.

.EXAMPLE
    Remove-BatchJob -Path "C:\Windows\Temp\cmd.bat" -InputFile "C:\Windows\Temp\TMP486.tmp" -TaskName "WindowsUpdateTask"

.LINK
    https://github.com/Spacecow99/Invoke-BatchJob

.NOTES
    Script must be run with Administrator privileges in order to delete scheduled task.

#>
    Param(
        [Parameter(Mandatory=$True, Position=0)]
        [String] $Path,

        [Parameter(Mandatory=$True, Position=1)]
        [String] $InputFile,
        
        [Parameter(Mandatory=$True, Position=2)]
        [String] $TaskName
    )

    If (([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
    {
        # Remove batch script, input file and output file
        Remove-Item -Path $Path -Force
        Remove-Item -Path $InputFile -Force
        Remove-Item -Path "$InputFile.ret" -Force

        # Connect to Schedule.Service COM Object
        $ScheduledService = New-Object -ComObject "Schedule.Service"
        $ScheduledService.Connect()

        # Get folder and delete target task
        $RootFolder = $ScheduledService.GetFolder("\")
        $RootFolder.DeleteTask($TaskName, 0)
    }
    Else
    {
        Throw [UnauthorizedAccessException]::New('Operation requires administrative priviledges.')
    }
}