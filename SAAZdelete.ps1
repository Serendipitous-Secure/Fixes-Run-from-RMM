$Services = get-service | where {$_.Name -match "SAAZ"}

if ( $Services.count -gt 0 ){

    foreach ($Service in $Services) {
        
        & sc.exe delete $Service.Name

    }

}