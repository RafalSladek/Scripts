
Function CreatePlaylist($baseDir) {
clear
Write-Host "Getting all artists..."
$artists = get-childitem $baseDir | Where {$_.psIsContainer -eq $true} 

foreach ($artist in $artists) {

     Write-Host "Processing Artist:  $artist"

     $artistPath = $artist.Fullname
     RemoveExitingM3UFile($artistPath)
     $musicFiles = GetAllMusicFileNames($artistPath)
     WriteM3UFile $artistPath $artist.Name "" $musicFiles
            
     $albums = get-childitem $artistPath | Where {$_.psIsContainer -eq $true}

        foreach ($album in $albums) {
            $albumPath = $album.Fullname
            RemoveExitingM3UFile($albumPath)
     
            $musicFiles = GetAllMusicFileNames($albumPath)
            WriteM3UFile $albumPath $artist.Name $album.Name $musicFiles
        }
    }
}

Function GetAllMusicFileNames($albumPath){
   Write-Host "Getting all music files in $albumPath"
   get-childitem -path $albumPath | where {$_.extension -eq ".mp3" -or $_.extension -eq ".wma" -or $_.extension -eq ".ogg" -or $_.extension -eq ".m4a" -or $_.extension -eq ".flac"}  | Sort-Object name | Foreach-Object {$_.Name} { $_.Name }      
}   

Function RemoveExitingM3UFile($currentDir){
    Write-Host "Deleting old playlist in $currentDir"
    remove-item "$currentDir\*.m3u" -ea SilentlyContinue -force
}

Function WriteM3UFile($targetDir, $artistName, $albumName, $musicFiles){
    if($musicFiles.count -gt 0) {
          $outfile = $targetDir + "\"+ $artistName +" - " + $albumName +".m3u"
          Write-Host "Creating playlist file $outfile"
          $musicFiles | out-file $outfile -encoding "UTF8"
    }
    else{
        Write-Host "No music files found in $targetDir"          
    }
}


#$dirToScan = "F:\98_Scanned_Music"
$dirToScan = "\\nas\music"


CreatePlaylist $dirToScan
