sc delete DockerVM
sc create DockerVM start= auto binPath= "\"C:\Program Files\Oracle\VirtualBox\VBoxManage\" startvm \"boot2docker-vm\" --type headless &"
pause