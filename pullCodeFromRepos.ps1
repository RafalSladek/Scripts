Function ListAllRepoDirs ($repoBaseDir, $folderName){
	Write-Host 'Trying to find all your' $folderName 'folders...'  -foregroundcolor "magenta"    
    try{      
		$PATH = "$repoBaseDir\*\*"
        $items = gci $PATH -force | where { $_.psiscontainer} | Where-Object {$_.Name -eq $folderName} | Select -ExpandProperty Parent
        $parents = $items | Select -ExpandProperty FullName
        
        Write-Host "Found "$parents.Length"$folderName repositories" -foregroundcolor "magenta"
        foreach ($item in $parents){
            Write-Host $item -foregroundcolor "green"
        }          
	}
	catch{
		Write-Warning $_.Exception
	}
    
    return $items
}

Function UpdateSVNrepos ($repoNames){
    Write-Host 'Starting svn update ...'  -foregroundcolor "magenta"
	foreach ($repo in $repoNames) {	        
        Write-Host 'SVN update ' $repo.FullName '...' -foregroundcolor "green"
        svn cleanup $repo.FullName 
        svn update $repo.FullName        
	}	 
    Write-Host 'Finished update from svn repositories' -foregroundcolor "magenta"
    cd $repoBaseDir
}

Function UpdateGitRepos ($repoNames){
    Write-Host 'Starting git update ...' -foregroundcolor "magenta"
	foreach ($repo in $repoNames) {      
        cd $repo.FullName
        Write-Host 'Git fetching and merging ' $repo'...' -foregroundcolor "green"
        git fetch
        git merge origin/master
    }	    
    Write-Host 'Finished update from git repositories' -foregroundcolor "magenta"
    cd $repoBaseDir
}

Function ZipFiles($targetDir, $repoBaseDir, $repoNames)
{
    if (-not (test-path "$env:ProgramFiles\7-Zip\7z.exe")) { throw "$env:ProgramFiles\7-Zip\7z.exe needed" } 
    set-alias sz "$env:ProgramFiles\7-Zip\7z.exe" 
    $sourceDir = $repoBaseDir     
    
    $bak = Get-ChildItem  -Path $sourceDir | where {$_.Attributes -eq 'Directory'}
	Write-Host 'Zipping all sources' $folderName 'folders...'  -foregroundcolor "blue"   
    foreach ($repo in $repoNames) { 	
         $targetDirName = "$repo.Name"".7z"	 
		 $targetPath = Join-Path $targetDir $targetDirName 
         Write-Host $repo.FullName "  ---->\t" 		$targetPath	
         sz a -t7z -mx9 "$targetPath" "$repo.FullName"      
    } 	
}

clear
$gitFolderName = '.git'
$svnFolderName = '.svn'
$repoBaseDir = 'D:\Sources'
$targetZipDir = 'D:\backup\Code'

$svnRepos = ListAllRepoDirs $repoBaseDir $svnFolderName
UpdateSVNRepos $svnRepos 
ZipFiles $targetZipDir $repoBaseDir $svnRepos 

$gitRepos = ListAllRepoDirs $repoBaseDir $gitFolderName
UpdateGitRepos $gitRepos 
ZipFiles $targetZipDir $repoBaseDir $gitRepos
