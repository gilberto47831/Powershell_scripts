param(
    # Parameter help description
    [Parameter(
        Mandatory=$true,
        ValueFromPipeline=$true,
        Position=0)]
    [string[]]$in

)

Begin {}

Process {
   
    $acl = Get-Acl $in
    
    Write-Output "Path: $in"
    Write-Output "Owner: $($acl.Owner)"
    $acl.Access | Format-Table -Property identityreference,filesystemrights,accesscontroltype -AutoSize
    Write-Output "`n"

}

End {}
