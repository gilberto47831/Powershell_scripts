Get-ChildItem "HKLM:\SYSTEM\CurrentControlSet\Control\Print\Monitors\Standard TCP/IP Port\Ports"

get-printer | ForEach-Object -Begin {
    Write-Output "`nPrinter Name/Port Name"
    Write-Output "----------------------"
} -Process {
    Write-Output "$($_.Name)/$($_.PortName)"
}
