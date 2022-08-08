param (
    #[Parameter(Mandatory=$true)]
    [string]$hostname,
    #[Parameter(Mandatory=$true)]
    [string]$model
)

$xerox_folder = "C:\Xerox Copier Drivers"
$resource_path = "\\seldon\world`$\gilbert\make-ready-usb\4. Copiers(Copy to C Drive)\Xerox Copier Drivers"

$drivers = @(
    "C:\Xerox Copier Drivers\AltaLink_C8030-C8070_5.639.3.0_PS_x64_Driver\x3ASKYP.inf"
    "C:\Xerox Copier Drivers\Xerox C8135 copier\AltaLinkC81xx_7.146.0.0_PS_x64\XeroxAltaLinkC81xx_PS.inf"
)

$c8035_model = "Xerox AltaLink C8035 PS"
$c8055_model = "Xerox AltaLink C8055 PS"
$c8135_model = "Xerox AltaLink C8135 V4 PS"
$c8145_model = "Xerox AltaLink C8145 V4 PS"


function usage {
    Write-Output "Usage: addprinter [-hostname <printer hostname>] [-model <model eg 8035/8135>]"
}

function addprinter {
    param(
        [string]$hostname,
        [string]$model
    )

    Add-PrinterDriver -Name $model
    Add-PrinterPort -Name $hostname -PrinterHostAddress $hostname
    Add-Printer -Name $hostname -DriverName $model -PortName $hostname

}

function main {

    if (!$hostname -or !$model) {
        usage
    }

    if (![System.IO.Directory]::Exists($xerox_folder)) {
        mkdir -Path $xerox_folder
    }

    ping -n 1 $hostname
    if (!$?) {
        Write-Error 'Hostname not found in network'
        exit 1
    }
    
    Robocopy.exe "$resource_path" "$xerox_folder" /E /IS /IT /IM

    foreach ($driver in $drivers) {
        pnputil.exe /add-driver $driver /install 
    }

    if ($model -match '.*8035.*') {
        addprinter $hostname $c8035_model
    }
    elseif ($model -match '.*8135.*') {
        addprinter $hostname $c8135_model
    }
    elseif ($model -match '.*8055.*') {
        addprinter $hostname $c8055_model
    }
    elseif ($model -match '.*8145.*') {
        addprinter $hostname $c8145_model
    }
    else {
        Write-Error 'Please specify correct xerox model'
    }
    
    get-printer -Name $hostname

    Restart-Service Spooler
}

main