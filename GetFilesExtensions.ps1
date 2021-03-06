Clear-Host
$extensions = @("")
$dirToScan = "F:\02_Todo_Espana"
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