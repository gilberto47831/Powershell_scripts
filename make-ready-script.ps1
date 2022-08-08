param
(
    [switch]$mitel, 
    [switch]$d = $false,
    [switch]$adobe,
    [switch]$drop
)

function install_browsers 
{
    if (((isInstalled("chrome")) -and (isInstalled("firefox"))) -eq $true) 
    {
        write-host "Browsers already installed"
        return
    }
    
    $arguments = "/silent", "/install"

    $chrome = [PSCustomObject]@{
        path = "$env:TEMP\chrome_installer.exe"
        uri = "http://dl.google.com/chrome/install/375.126/chrome_installer.exe"
    }

    Invoke-WebRequest -Uri $chrome.uri -UseBasicParsing -OutFile $chrome.Path
    start-process -Wait -FilePath $chrome.path -ArgumentList $arguments -PassThru
    Remove-Item -Force $chrome.path

    
    #install firefox 
    $firefox = [PSCustomObject]@{
        path = "$env:TEMP\Firefox-latest-stable.exe"
        uri = "https://download.mozilla.org/?product=firefox-latest&os=win&lang=en-US"
    }

    Invoke-WebRequest -Uri $firefox.uri -UseBasicParsing -OutFile $firefox.Path
    start-process -Wait -FilePath $firefox.path -ArgumentList $arguments -PassThru
    Remove-Item -Force $firefox.path

    write-host "Browsers installed!"

}

function install_cpp_libs 
{

    $arguments = "/silent", "/install"

    $vcredist_x64 = [PSCustomObject]@{
        path = "$env:TEMP\vc_redist.x64.exe"
        uri = "https://aka.ms/vs/17/release/vc_redist.x64.exe"
    }

    Invoke-WebRequest -Uri $vcredist_x64.uri -UseBasicParsing -OutFile $vcredist_x64.path
    start-process -Wait -FilePath $vcredist_x64.path -ArgumentList $arguments -PassThru
    Remove-Item -Force $vcredist_x64.path

    $vcredist_x86 = [PSCustomObject]@{
        path = "$env:TEMP\vc_redist.x86.exe"
        uri = "https://aka.ms/vs/17/release/vc_redist.x86.exe"
    }

    Invoke-WebRequest -Uri $vcredist_x86.uri -UseBasicParsing -OutFile $vcredist_x86.path
    start-process -Wait -FilePath $vcredist_x86.path -ArgumentList $arguments -PassThru
    Remove-Item -Force $vcredist_x86.path

    #$vc_x64 = ".\1. Install First\Microsoft Visual C++ Redistributable\VC_redist.x64.exe"


    #install x86 c++ libs
    #start-process -Wait -FilePath $vc_x86 -ArgumentList $arguments -PassThru
    #install x64 c++ libs

    write-host "Cpp libs installed!"

}

function install_mitel
{
    if ((isInstalled("Mitel")) -eq $true) 
    {
        write-host "Mitel already installed"
        return
    }

    #sfc /scannow
    #dism /online /cleanup-image /restorehealth

    $mitel = ".\1. Install First\5. MitelConnect.exe"
    $arguments = "/S", "/v/qn"

    for($i = 0; $i -lt 1; $i++)
    {
        Start-Process -Wait -FilePath $mitel -ArgumentList $arguments -PassThru
        delete_mitel
    }

    Start-Process -Wait -FilePath $mitel -ArgumentList $arguments -PassThru

}

function delete_mitel
{
    Get-Package -Name "Mitel Presenter" | Uninstall-Package -Force
    Get-Package -Name "Mitel Connect" | Uninstall-Package -Force
}

function install_teamviewer
{
    if ((isInstalled("teamviewer")) -eq $true) 
    {
        write-host "Teamviewer already installed"
        return
    }

    $teamviewer = '.\1. Install First\1. TeamViewer_Host_Setup.exe'
    $arguments = "/S"

    Start-Process -Wait -FilePath $teamviewer -ArgumentList $arguments -PassThru

}

function install_office
{
    if ((isInstalled("Microsoft office professional Plus 2019")) -eq $true) 
    {
        write-host "Office already installed"
        return
    }

    mkdir 'C:\office2019'

    $setup_file = "C:\office2019\setup.exe"
    $arguments = "/configure", "C:\office2019\configuration.xml"

    robocopy '.\3. Office Copy Folder Inside C Drive & Delete After Installed\office2019' 'C:\office2019' /E /IS /IM /IT

    Start-Process -Wait -FilePath $setup_file -ArgumentList $arguments -PassThru

    Remove-Item -r -Force 'C:\office2019\'
}

function install_adobe 
{
    if ((isInstalled("adobe")) -eq $true) 
    {
        write-host "Adobe already installed"
        return
    }

    $adobe = [PSCustomObject] @{ 
        path = "$env:TEMP\readerdc64.exe"
        uri = "https://admdownload.adobe.com/rdcm/installers/live/readerdc64.exe"
    }

    Invoke-WebRequest -Uri $adobe.uri -UseBasicParsing -OutFile $adobe.path
    start-process -FilePath $adobe.path -PassThru

    while ((!(@(Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*).DisplayName -match "adobe")) `
        -and (!(@(Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*).DisplayName -match "adobe")))
    {
        start-sleep -s 5
    }
}

function install_vpn 
{
    if ((isInstalled("GlobalProtect")) -eq $true)
    {
        write-host "VPN already installed"
        return
    }
    
    $gp = "$(pwd)" + "\VPN For Laptops\GlobalProtect64.msi"

    # $abs_path = pwd
    # $abs_path = $abs_path.path + '\GlobalProtect64.msi'

    $arguments = "/i", "`"$gp`"", "/quiet", "/qn"

    Start-Process -FilePath "msiexec.exe" -ArgumentList "$arguments" -Wait -PassThru

}

function install_dropbox
{
    if ((isInstalled("dropbox")) -eq $true) 
    {
        write-host "Dropbox already installed"
        return
    }
    $dropbox = [PSCustomObject]@{
        path = "$env:TEMP\DropboxInstaller.exe"
        uri = "https://www.dropbox.com/download?plat=win"
    }

    $arguments = "/S"

    Invoke-WebRequest -Uri $dropbox.uri -UseBasicParsing -OutFile $dropbox.path
    Start-Process -Wait -FilePath $dropbox.path -ArgumentList $arguments -PassThru
    Remove-Item -Force $dropbox.path

}

function xerox_copiers 
{
    mkdir 'C:\Xerox Copier Drivers'

    robocopy '.\4. Copiers(Copy to C Drive)\Xerox Copier Drivers' 'C:\Xerox Copier Drivers' /E /IS /IM /IT

    write-host "Xerox drivers copied!"
}

function disable_ipv6
{
    #disable ipv6
    write-host "Disabling ipv6..."
    #Disable-NetAdapterBinding -Name "Ethernet" -ComponentID ms_tcpip6
    Get-NetAdapter | ForEach-Object { $_ | Disable-NetAdapterBinding -ComponentID ms_tcpip6 }
    write-host "Ipv6 disabled"
}

function update_power_settings 
{  
    write-host "Updating power settings..."
    #change power settings
    powercfg /change monitor-timeout-dc 15
    powercfg /change monitor-timeout-ac 30

    powercfg /change standby-timeout-dc 30
    powercfg /change standby-timeout-ac 0

    powercfg /change disk-timeout-dc 0
    powercfg /change disk-timeout-ac 0

    #get powerplan
    $guid = powercfg -list | Where-Object { $_ -match 'High'}

    #regex to get only guid portion
    if ($guid)
    {
        $guid = $guid -replace '.*GUID:\s*([-a-f0-9]+).*', '$1'
        #set power plan
        powercfg -SETACTIVE $guid        

        Write-Host "Power settings udpated!"
    }

    #change close lid action to nothing
    if (!$d) 
    {
        Write-Output "Changing lid actions..."

        $scheme = (powercfg -getactivescheme) -replace '.*GUID:\s*([-a-f0-9]+).*', '$1'
        $sub_group = (powercfg -query | Where-Object { $_ -match  '.*(Power Buttons and lid).*'}) -replace '.*GUID:\s*([-a-f0-9]+).*', '$1'
        $lid = "5ca83367-6e45-459f-a27b-476b1d01c936"  
        #0 == Do Nothing
        powercfg -setacvalueindex $scheme $sub_group $lid 0
        powercfg -setdcvalueindex $scheme $sub_group $lid 0 
    }

    #don't allow device to turn off
    $adapters = Get-NetAdapter -Physical | Get-NetAdapterPowerManagement
    
    foreach ($adapter in $adapters)
    {
        if ($adapter.AllowComputerToTurnOffDevice -match 'Enabled')
        {
            $adapter.AllowComputerToTurnOffDevice = 'Disabled'
            $adapter | Set-NetAdapterPowerManagement
            
        }
    }
}

function isInstalled([string]$app)
{
    write-host $app
    if (((@(Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*).DisplayName -match $app)) `
        -or ((@(Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*).DisplayName -match $app)))
    {
        return $true 
    }
    else 
    {
        return $false
    }

}

function disableOfflineFiles
{
    Get-CimInstance -ClassName 'win32_offlinefilescache' | Invoke-CimMethod -MethodName Enable -Arguments @{enable=$false}
}

function foo
{
    for (($i = 0), ($j = 0); $i -lt 10 -and $j -lt 10; $i++,$j++)
    {
        Write-Host `$i:$i
        Write-Host `$j:$j
    }

    Write-Output $arg
}

######START OF SCRIPT########
if ($mitel)
{
    if ((isInstalled("Mitel")) -eq $true)
    {
        delete_mitel
    }

    install_mitel

    exit
}

if ($drop)
{
    install_dropbox
    exit
}

if ($adobe)
{
    install_adobe
    exit
}

if (!$d)
{   
    install_vpn
} 

#make ready procedures
update_power_settings
disable_ipv6

xerox_copiers

install_browsers
install_teamviewer
install_dropbox
install_cpp_libs
install_office
install_mitel
install_adobe
disableOfflineFiles

write-host "=========================================="
write-host "Done!"
write-host "=========================================="