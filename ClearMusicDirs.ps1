Clear-Host
$dirToScan = "F:\02_Todo_Espana"

Function ClearMusicDirsIsNoMusicContians($dirToScan) {
    Get-ChildItem -Path $dirToScan -rec | ForEach-Object {
        if ($_.PSIsContainer -eq $true) {
            $path = $_.FullNamei
              
            $children = Get-ChildItem -Path $path
            if ($children -eq $null) {
                Write-Host "$path is empty."
                RemoveDir($path)
            } else {
                $path = $_.FullName
                $files =  Get-ChildItem -Path $path -Recurse -Include  "*.mp3", "*.wma", "*.ogg", "*.m4a", "*.flac" |  Group-Object Extension 
                            
                if ($files -eq $null){
                   Write-Host "No music files in " $path
                   RemoveDir($path)
                }
            }
        }
    } 

    Write-Host "completed"
}

Function CleanUpDirNames($dirToScan){     
     Get-ChildItem -Path $dirToScan -Recurse | where {$_.PSIsContainer} | % { Rename-Item -Path $_.PSPath -NewName $_.Name.replace("[","")}    
}

Function RemoveDir($path){
     Get-ChildItem -Path "$path\*" -Recurse | Remove-Item -Force -Recurse
     Remove-Item "$path" -Recurse -Force
     Write-Host "Removed $path"
}
clear-host
       

#CleanUpDirNames $dirToScan
ClearMusicDirsIsNoMusicContians $dirToScan