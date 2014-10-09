Clear-Host
$extensions = @("")
$dirToScan = "C:\Users"
$files = get-childitem $dirToScan -rec | where {!$_.PSIsContainer} 

ForEach ($file in $files){
    $ext = $file.Extension
    If ($extensions -notcontains $ext)
    {        
        $extensions += $ext
    }
}

Write-Host "Extensions in $dirToScan : "
ForEach ($ext in $extensions){	
    Write-Host $ext
}

Write-Host "completed"