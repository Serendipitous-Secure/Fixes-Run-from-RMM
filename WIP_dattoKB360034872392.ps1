
#Create Working Lists 
$RawVolumes = Get-WmiObject win32_logicaldisk | Where-Object -FilterScript {($_.DriveType -match 3)} | Select-Object -Property DeviceID
$ProtectedVolumes = @()
$GoodVolumes = @()
$FragmentedVolumes = @()
$UnfixedVolumes = @()

#stopping necessary services.
sc stop dattofsf

# test for datto.ctl
foreach ( $Volume in $RawVolumes ) {
    
    $Path = -join($Volume.DeviceID, "datto.ctl")

    if ( Test-Path -Path $Path ){

        $ProtectedVolumes += [PSCustomObject]@{
            Drive = $Volume.DeviceID
            ctlFile = -join($Volume.DeviceID, "datto.ctl")
            mifFile = -join($Volume.DeviceID, "datto.mif")
            Fragments = 0
        }

    }

}

if ( $ProtectedVolumes.count -gt 0 ) {

    Write-Host "-------------------------------------------------------------------"
    Write-Host "These Volumes are protected. Testing these volumes for Fragmentation."
    $ProtectedVolumes
    Write-Host "------------------------------------------------------------------"
    #Running Fragmentation Check
    foreach ( $Volume in $ProtectedVolumes ) {
    
        $Volume.Fragments = contig.exe -a $Volume.ctlFile | foreach-object{ if($_ -match "is in (?<Fragments>.*)") {$($Matches['Fragments'])}}
        Write-Host $Volume | Select-Object -Property DriveLetter,Fragmentation

    }

    foreach ( $Volume in $ProtectedVolumes ) {

       if ( $Volume.Fragments -lt  10240) {

           $GoodVolumes += $Volume

      } else {
        
           $FragmentedVolumes += $Volume

    }

}

if ( $FragmentedVolumes.count -gt 0 ) {
 
    Write-Host "------------------------------------------------------------------"
    Write-Host "Fragmentation Found on the Following Volumes."
    Wrote-Host $FragmentedVolumes | Select-Object -Property DriveLetter 
    Write-Host "Attempting To defragment."
    Write-Host "------------------------------------------------------------------"

    c:\Program Files\Datto\drivers\util\DattoSnapshot.exe -ra
   
    foreach ( $Volume in $FragmentedVolumes ) {
        
        Contig.exe -a $Volume.ctlFile 
        Contig.exe -a -v $Volume.ctlFile

    }
    
    foreach ( $Volume in $FragmentedVolumes ) {
       
        $Volume.Fragments = contig.exe -a -v $Volume.ctlFile | foreach-object{ if($_ -match "is in (?<Fragments>.*)") {$($Matches['Fragments'])}}
        Write-Host $Volume | Select-Object -Property DriveLetter,Fragmentation

    }
    
    foreach ( $Volume in $FragmentedVolumes ) {
    
        if ( $Volume.Fragments -lt  10240) {
    
            $GoodVolumes += $Volume
    
        } else {
            
            $UnfixedVolumes += $Volume

        }
        
    }

    if ( $UnfixedVolumes.count -gt 0 ) {
    
        Write-Host "------------------------------------------------------------------"
        Write-Host "The Following Drives Remain Fragmented."
        Wrote-Host $UnfixedVolumes | Select-Object -Property DriveLetter 
        Write-Host "Attempting a Full Disk Defragmentation."
        Write-Host "------------------------------------------------------------------"
    
    
        foreach ( $Volume in $UnfixedVolumes ) {
    
            defrag $Volume.DriveLetter /v 
            
        }
    
        sc start dattofsf
    
        Write-Host "------------------------------------------------------------------"
        Write-Host "The Protected drives on this should have completed Defragmentation."
        Write-Host "------------------------------------------------------------------"
        Write-Host "Please Reattempt a backup."
        Write-Host "------------------------------------------------------------------"
        exit 0

    }else {
    
        Write-Host "------------------------------------------------------------------"
        Write-Host "The Protected drives should have defragmented for datto Please attempt to resume updates."
        Write-Host "------------------------------------------------------------------"
        exit 0
    }
    

}else{

    Write-Host "------------------------------------------------------------------"
    Write-Host "The Protected drives do not show signs of fragmentation. Please Attempt another backup."
    Write-Host "------------------------------------------------------------------"

    sc start dattofsf
    exit 0
}
}else{

    Write-Host "------------------------------------------------------------------"
    Write-Host "Did not detect any protected drives."
    Write-Host "------------------------------------------------------------------"

}


#if preform freespace check
    #for each volume with datto.ctl
    #Contig.exe -f C: