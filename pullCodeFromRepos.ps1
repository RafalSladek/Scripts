param(
	[string]$repoBaseDir = 'D:\Sources',
	[string]$targetZipDir = 'G:\AS24\Code'
)

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
        #svn cleanup $repo.FullName 
        svn update $repo.FullName        
	}	 
    Write-Host 'Finished update from svn repositories' -foregroundcolor "magenta"
    cd $repoBaseDir
}

Function UpdateGitRepos ($repoNames){
    Write-Host 'Starting git update ...' -foregroundcolor "magenta"
    git config --global http.sslVerify false
	foreach ($repo in $repoNames) {      
        cd $repo.FullName
        Write-Host 'Git pull --rebase ' $repo'...' -foregroundcolor "green"
        git pull --rebase origin master
    }	    
    git config --global http.sslVerify true
    Write-Host 'Finished update from git repositories' -foregroundcolor "magenta"
    cd $repoBaseDir
}

Function ZipFiles($targetDir, $repoNames)
{
    if (-not (test-path "$env:ProgramFiles\7-Zip\7z.exe")) { throw "$env:ProgramFiles\7-Zip\7z.exe needed" } 
    set-alias sz "$env:ProgramFiles\7-Zip\7z.exe"     
	Write-host $sz
	Write-Host 'Zipping all sources' $folderName 'folders...'  -foregroundcolor "blue"   
    foreach ($repo in $repoNames) { 
         $targetDirName = $repo.Name
		 $archiveName = Join-Path $targetDir $targetDirName         
         $filesToZip = $repo.FullName 
		 $archiveName	= "$archiveName.7z"	
         Write-Host $filesToZip "  ---->" $archiveName			 
         if (Test-Path $archiveName) {
			sz u "$archiveName" "$filesToZip"
		 }Else{
			sz a -t7z -mx9 -ms=off  -xr!bin -xr!obj -x!.pdb "$archiveName" "$filesToZip" 
		 }	       
    } 	
}

Function ListAllCsProj($repoBaseDir){
	Write-Host 'Trying to find all your csproj files...'  -foregroundcolor "magenta"   
    $items = gci $repoBaseDir -rec -ErrorAction SilentlyContinue | where {! $_.psiscontainer} | Where-Object {$_.Extension -eq ".csproj"} | Select -ExpandProperty FullName
    Write-Host "Found "$items.Length"csproj files" -foregroundcolor "magenta"
    foreach ($item in $items){
        Write-Host $item -foregroundcolor "green"
    } 
    
    return $items
}

Function CleanWithMSBuild($listOfCsProj){
    foreach ($csproj in $listOfCsProj){
        Write-Host "Msbuild clean for $csproj" -foregroundcolor "magenta"
        MSbuild.exe $csproj /t:Clean
    }
}

Function Main($repoBaseDir, $targetZipDir){
	clear
	$gitFolderName = '.git'
	$svnFolderName = '.svn'

	#$csprojs = ListAllCsProj $repoBaseDir
	#CleanWithMSBuild $csprojs
	$gitRepos = ListAllRepoDirs $repoBaseDir $gitFolderName
	UpdateGitRepos $gitRepos 
	ZipFiles $targetZipDir $gitRepos	
	
	$svnRepos = ListAllRepoDirs $repoBaseDir $svnFolderName
	UpdateSVNRepos $svnRepos 	
	ZipFiles $targetZipDir $svnRepos 		
}

Main $repoBaseDir $targetZipDir
