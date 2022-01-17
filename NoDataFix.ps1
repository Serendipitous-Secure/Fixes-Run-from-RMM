function Repair-NoData {
    
    Write-Host "Running preliminary scans... `n"
    Repair-WindowsImage -Online -RestoreHealth  
    sfc /scannow

    try {
        
        Write-Host "Installing Module to interact with Windows Updates... `n"
        Set-ExecutionPolicy Unrestricted -Scope Process -force -ErrorAction Stop
        Install-PackageProvider Nuget -Force -ErrorAction Stop
        install-Module PSWindowsUpdate -Force -ErrorAction Stop
        Import-Module PSWindowsUpdate -Force -ErrorAction Stop
    
        try {
            
            Write-Host "Scanning for updates to bring updated patch data to Datto... `n"
            Get-WindowsUpdate -MicrosoftUpdate -Verbose -ErrorAction Stop

            Write-Host "Preform a device audit on device(s) to verify repaired patch status."

            exit 0

        }
        catch {
            
            Write-Host "Could Not Scan For updates... Exiting"
            
            $ExitingError = $Error[0]
            $ExitingError
            
            exit 1

        }

    }
    catch {
        
        Write-Host "Could not install module... Exiting"
        
        $ExitingError = $Error[0]
        $ExitingError
        
        exit 1

    }

}
