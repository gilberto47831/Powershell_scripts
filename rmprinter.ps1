param(
    #[Parameter(Mandatory=$true)]
    [string]$name,
    [string]$portname
)

function usage {
    Write-Output 'Usage: rmprinter [-name <Printer Name>] [-portname <PortName>]'
    exit 1

}
function main {

    if (!$name -or !$portname) {
        usage
    }

    $key_path = "HKLM:\SYSTEM\CurrentControlSet\Control\Print\Monitors\Standard TCP/IP Port\Ports" + "\$portname"

    Get-Printer -name '*$name*' | Remove-Printer
    if ($?) { Write-Output "Printer removed successfuly!"}

    if (Test-Path -Path "$key_path") { Remove-Item -Path "$key_path" }
    
    Write-Output "Port removed successfully!"

    #This command is inconsistent, so just remove registery key 
    #Remove-PrinterPort -Name $portname

    Restart-Service Spooler
}

main