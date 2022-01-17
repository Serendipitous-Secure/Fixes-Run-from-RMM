function Remove-PendingFileRenameOperations {

    <#
    .SYNOPSIS
        This function attempts to fix a persistent "Reboot Required" when that status is caused by the "PendingFileRenameOperation" property.
    .DESCRIPTION
        This function checks for the existence of the "PendingFileRenameOperation" property, and then deletes it. Then, if instructed to do so, will exit with the appropriate status.
    .PARAMETER EXIT
        This Paramter answers the yes or no question to exit upon completion. <y|yes>/<n|no> Defaults to No.
    .EXAMPLE
        #To exit appropriately
            Remove-PendingFileRenameOperations -exit yes
            Remove-PendingFileRenameOperations -exit y
        #To finish without exiting
            Remove-PendingFileRenameOperations
    #>
    
    [CmdletBinding(SupportsShouldProcess)]
    param( 
    
    [ValidateSet ("y", "yes", "n", "no", IgnoreCase=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$Exit = "N"

    )

    Write-Host "Searching for property..."
    $RegCheck = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager" -Name "PendingFileRenameOperations"
    $FailFlag = 0

    if ( $RegCheck ) {

        Write-Host 'Registry Item "PendingFileRenameOperations" found. Deleting property.'
        Write-Host $RegCheck
        
    
    } else {

        Write-Host 'Registry Item "PendingFileRenameOperations" Not found. Failing Action...'
        $FailFlag = 1

    }

    if ( $FailFlag -gt 0 ) {

        Write-Host "Checking work..."
        $RegCheck = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager" -Name "PendingFileRenameOperations"

        if ( $RegCheck ) {
                        
            Write-Host 'The "PendingFileRenameOperations" is still present.'
            Write-Host "Printing information..."
            Write-Host $RegCheck

        }

    }
    

    if ( ($Exit -match "y") -or ($Exit -match "yes") ){

        Write-Host "Exiting Appropriately..."

        if ( $FailFlag -gt 0 ) {
        
            Write-Host "ExitCode:1"
            exit 1 
        
        } else {
    
            Write-Host "ExitCode:0"
            exit 0
            
        }

    }else {

        Write-Host "Instructed not to exit."

    }

}

if ( $ENV:WhatIf -match "false" ) {
    
    Remove-PendingFileRenameOperations -Exit "Y"

} else {

    Remove-PendingFileRenameOperations -Exit "Y" -WhatIf

}

