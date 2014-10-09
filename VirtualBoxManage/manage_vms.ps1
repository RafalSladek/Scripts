clear

$vboxManage = "C:\Program Files\Oracle\VirtualBox\VBoxManage"

Function startVM ($vmName) {
    & $vboxManage startvm "$vmName" --type headless
}

Function stopVM ($vmName) {
    & $vboxManage controlvm "$vmName" acpipowerbutton
}

