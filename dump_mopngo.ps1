param ([string]$MONGO = "")

# setup
$LIVE_USERNAME = 'smp'
$LIVE_Server = 'LMGRSMV00'
$LIVE_Password = '0wMPEqES7uLV7'
$LIVE_SMP_DATABASENAME = 'smp'
$LIVE_TAXONOMY_DATABASENAME = 'taxonomy_a'

$LIVE_GSI_USER = 'asmgsi'
$LIVE_GSI_PASSWORD = '43e5gh%'
$LIVE_GSI_DATABASE = 'GarageSearchInternational'


$REF_USERNAME = 'rebasement'
$REF_Server = 'RMGRSMV00'
$REF_Password = '0wMPEqES7uLV7'

$Number_Of_MongoDB_Instances = 2

Function Dump ($SERVER, $USERNAME, $PASSWORD, $Number_Of_MongoDB_Instances, $MONGO, $DBName)
{
	for ($i =1; $i -le $Number_Of_MongoDB_Instances; $i++)
	{
		$SERVER_LIVE_SECONDARY = $SERVER + $i
		$Is_LIVE_Secondary = invoke-expression($MONGO + "mongo.exe -p " + $PASSWORD + " -u " + $USERNAME + " " + $SERVER_LIVE_SECONDARY + "/" + $DBName + " --quiet --eval `"rs.isMaster().secondary`"")
		
		# find the first LIVE secondary
		if($Is_LIVE_Secondary -eq 'true')
		{
			$SERVER_TO_USE = $SERVER_LIVE_SECONDARY
			WRITE-HOST $SERVER_TO_USE " is master"
		}
	}

	$RebaseFolder = $DBName + "\" + $SERVER_TO_USE
	WRITE-HOST $RebaseFolder " target dir"
	
	#WRITE-HOST $SERVER_LIVE_SECONDARY " is secondary"
	if (Test-Path $RebaseFolder) {
		remove-item $RebaseFolder -recurse -force
	} else {
		new-item $RebaseFolder -itemType directory
	}
	WRITE-HOST "Dumping..."
	invoke-expression($MONGO + "mongodump.exe -p " + $PASSWORD + " -u " + $USERNAME + " -h " + $SERVER_TO_USE + " -d " + $DBName + " -o " + $RebaseFolder)
}

Function ZipFiles($repoNames)
{
    if (-not (test-path "$env:ProgramFiles\7-Zip\7z.exe")) { throw "$env:ProgramFiles\7-Zip\7z.exe needed" } 

    set-alias sz "$env:ProgramFiles\7-Zip\7z.exe" 
    $sourceDir = "C:\Users\rsladek\Desktop\mongo" 
    $targetDir = "C:\Users\rsladek\Desktop\mongo\zips" 
    
    $bak = Get-ChildItem  -Path $sourceDir | where {$_.Attributes -eq 'Directory'}
	Write-Host 'Zipping all sources' $folderName 'folders...'  -foregroundcolor "red"   
	if (Test-Path $targetDir) {
		Write-Host "Cleaning old zip archives in " $targetDir
		remove-item $targetDir -recurse -force
	} else {
		new-item $targetDir -itemType directory
	}
	
    foreach ($repo in $repoNames) {   
		 $path = Join-Path $sourceDir $repo
		 $targetPath = Join-Path $targetDir $repo
		 $targetPath += '.7z'         
         Write-Host "Compressing $repo into 200MB chunks"
		 sz a -t7z -mx9 "$targetPath" "$path" -v200m     
		 #sz a -v100m "$targetPath" "$path"     
    } 	
	 Write-Host 'Finished zipping folders' -foregroundcolor "magenta"
}
clear
Dump $LIVE_Server $LIVE_USERNAME $LIVE_Password $Number_Of_MongoDB_Instances $MONGO $LIVE_SMP_DATABASENAME
Dump $LIVE_Server $LIVE_USERNAME $LIVE_Password $Number_Of_MongoDB_Instances $MONGO $LIVE_TAXONOMY_DATABASENAME
Dump $LIVE_Server $LIVE_GSI_USER $LIVE_GSI_PASSWORD $Number_Of_MongoDB_Instances $MONGO $LIVE_GSI_DATABASE

ZipFiles $LIVE_GSI_DATABASE, $LIVE_TAXONOMY_DATABASENAME, $LIVE_SMP_DATABASENAME
ZipFiles $LIVE_TAXONOMY_DATABASENAME
ZipFiles $LIVE_SMP_DATABASENAME
Read-Host "Completed, press any key.."
