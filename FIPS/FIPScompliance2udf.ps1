###########################################################
# IMPORTANT
# Runs as scheduled job. When enabled fips, fips compliance breaks monitors.
###########################################################

$ErrorActionPreference = "Stop"
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Unrestricted -Force
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$UDF = "Custom14"

try {

    $FIPSsetting = reg query HKLM\System\CurrentControlSet\Control\Lsa\FIPSAlgorithmPolicy /v Enabled

} catch {

    Write-Host "`n"
    Write-Host "============================================================"
    Write-Host "Could not query registry for this key: HKLM\System\CurrentControlSet\Control\Lsa\FIPSAlgorithmPolicy"
    Write-Host "============================================================"
    Write-Host "`n"

    $Error

    exit 1

}

if ( $FIPSsetting -match "0x0" ){

    Write-Host "`n"
    Write-Host "============================================================"
    Write-Host "HKLM\System\CurrentControlSet\Control\Lsa\FIPSAlgorithmPolicy"
    Write-Host "This server does not enforce FIPS compliance!"
    Write-Host "============================================================"
    Write-Host "`n"

    $UDFmessage = "Not Enforced. Compatible"

} elseif ( $FIPSsetting -match "0x1" ) {
    
    Write-Host "`n"
    Write-Host "============================================================"
    Write-Host "HKLM\System\CurrentControlSet\Control\Lsa\FIPSAlgorithmPolicy"
    Write-Host "This server enforces FIPS compliance!"
    Write-Host "============================================================"
    Write-Host "`n"

    $UDFmessage = "Enforced. Not Compatible"

} else {

    Write-Host "`n"
    Write-Host "============================================================"
    Write-Host "Could not interpret output for query registry for this key: HKLM\System\CurrentControlSet\Control\Lsa\FIPSAlgorithmPolicy"
    Write-Host "============================================================"
    Write-Host "`n"

}

& REG ADD HKEY_LOCAL_MACHINE\SOFTWARE\CentraStage /v $UDF /t REG_SZ /d $UDFmessage /f

exit 0