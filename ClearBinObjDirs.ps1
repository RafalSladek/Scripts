Clear-Host
$dirToScan = "C:\Sources"

Function RemoveBinObjDir($path){
     Get-ChildItem path -include bin,obj -Recurse | foreach ($_) { remove-item $_.fullname -Force -Recurse -WhatIf }
     Write-Host "Removed $path"
}

RemoveBinObjDir $dirToScan