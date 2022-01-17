#!ps

& sc.exe config VSS start= disabled 

if ( !(( & vssadmin.exe list shadows ) -match "No items found") ){

    & vssadmin.exe delete shadows /all

}