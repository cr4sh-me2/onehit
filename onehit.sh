#!/bin/bash

interface=wlan0

check_update(){
    changed=0
    git remote update && LC_ALL=C git status -uno | grep -q 'Your branch is behind' && changed=1
        if [ $changed = 1 ]; then
            updates=1
            updates_string="\e[0m\e[92mUpdate avaiable!\e[0m"
        else
            updates=0
            updates_string="\e[0m\e[93mNo updates avaiable\e[0m"
fi
}

update_me(){

    if [ $updates == 1 ]; then
        printf "\n\e[0m[\e[93m*\e[0m] Updating OneHit script! Please wait... \n"
        git stash
        git stash drop
        git pull
        printf "\n\e[0m[\e[92mi\e[0m] Done! Press [ENTER] to run updated script \n"
        read ener_empty_value
        exit
        sudo bash onehit.sh

    else
        printf "\n\e[0m[\e[91m!\e[0m] There is no updates avaiable! \n"
    fi

}

banner(){
    clear
    cat config/banner.txt
}

scan_wps(){
    banner
    printf "\n\e[0m[\e[92mi\e[0m] Scanning on default interface \e[92m$interface\e[0m, you can change it in settings"
    printf "\n\e[0m[\e[93m*\e[0m] Searching for wps networks! Please wait... \n"
}

settings_menu(){
    banner
    printf "
[ Choose option: ]

[1] Update script
[2] Change settings
[*] Back

"
read -p "Choice: " menuchoice

case $menuchoice in
1) update_me;;
2) config_settings;;
*) onehit_menu;;
esac

}

onehit_menu(){
    banner
    printf "| \e[0m\e[96mOneHit UI v1\e[0m | \e[0m\e[95mgithub.com/rkhunt3r/onehit\e[0m | $updates_string |

[ Choose option: ]

[1] Scan for WPS networks
[2] Configure & run OneShot
[3] Settings
[*] Exit

"
read -p "Choice: " menuchoice

case $menuchoice in
1) scan_wps;;
2) start_oneshot;;
3) settings_menu;;
*) exit;;
esac

}

check_update
onehit_menu