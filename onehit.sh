#!/bin/bash

check_update(){
    changed=0
    git remote update && git status -uno | grep -q 'Your branch is behind' && changed=1
        if [ $changed = 1 ]; then
            # git pull
            # echo "\n\e[0m[\e[92mi\e[0m] Need update \n";
            updates_string="\e[0m[\e[92mUpdate avaiable!\e[0m]"
        else
            # echo "\n\e[0m[\e[92mi\e[0m] No need for update \n"
            updates_string="\e[0m\e[93mNo updates avaiable\e[0m"

fi
}

banner(){
    clear
    cat config/banner.txt
}

onehit_menu(){
    banner
    printf "| \e[0m\e[96mOneShot UI v1\e[0m | \e[0m\e[95mgithub.com/rkhunt3r/onehit\e[0m | $updates_string |"
    printf "UPDATE TEST STRING"
}

check_update
onehit_menu
