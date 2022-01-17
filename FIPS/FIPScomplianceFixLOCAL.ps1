$ErrorActionPreference = "Stop"
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Unrestricted -Force
#[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$RSOP = ( . gpresult.exe /z)

if ( !($ENV:UDF_14 -match "Enforced. Not Compatible") ) {

    if ( (Get-WmiObject -Class Win32_ComputerSystem).PartOfDomain ) {

        if ( ($RSOP -match " fips ") -or ($RSOP -match "FIPSAlgorithmPolicy") ){

            Write-Host "`n"
            Write-Host "============================================================"
            Write-Host "FIPS enabled by GPO. Please Disable GPO at Domain Controller."
            Write-Host "============================================================"
            Write-Host "`n"

            exit 0

        } else {

            try{

                Set-ItemProperty -Path HKLM:\System\CurrentControlSet\Control\Lsa\FIPSAlgorithmPolicy -Name Enabled -Value 0

                Write-Host "`n"
                Write-Host "============================================================"
                Write-Host "GPO setting Not Detected, Removing Registry Key."
                Write-Host "============================================================"
                Write-Host "`n"

                exit 0

            } catch {

                Write-Host "`n"
                Write-Host "============================================================"
                Write-Host "GPO setting Not Detected, Removing Registry Key FAILED."
                Write-Host "============================================================"
                Write-Host "`n"

                exit 1

            }
        }

    }

}
