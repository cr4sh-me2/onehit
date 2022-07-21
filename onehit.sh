#!/bin/bash

target="none"
target_ports="none"
target_service_vendor="none"
gateway=$(ip route | grep -v 'default' | awk '{print $1}')

## CONFIG ###

settings_file="config/settings.conf"
source $settings_file
# scan_t=4
# camera_ports="554,80,5554,8554"
#

check_root(){
    if [[ $EUID -ne 0 ]]; then
    printf "\n\e[0m[\e[91m!\e[0m] Run this script as root! \n"
    exit 1
fi
}

check_internet(){
    printf "\n\e[0m[\e[93m*\e[0m] Checking for internet connection... \n"
    if ! ping -q -c1 google.com &>/dev/null; then
    printf "\e[0m[\e[91m!\e[0m] Network isn't avaiable! \n" && exit
    fi
}

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

back_to_menu(){
    printf "\n\e[0m[\e[92mi\e[0m] Press [ENTER] to return to menu\n"
    read ener_empty_value
    onehit_menu
}

empty_input(){
    if [ -z "$input" ];
    then
        printf "\n\e[0m[\e[91m!\e[0m] Input can't be empty!";
        back_to_menu
    fi
}

default_scan_time(){
   printf "\n\e[0m[\e[92mi\e[0m] Current nmap scan time = $scan_t\n"
    read -p "New value: " input
    empty_input
    sed -i "s/scan_t\=.*/scan_t=$input/" $settings_file
    source $settings_file
    config_settings
}

config_settings(){
    banner
    printf "[ Select setting to edit: ]\n
[1] Nmap scan time
[2] Default camera ports
[*] Back\n
"
    read -p "Choice: " sel
    case $sel in
    1) default_scan_time;;
    2) default_camera_ports;;
    *) settings_menu ;;
    esac
}

update_me(){

    if [ $updates == 1 ]; then
        printf "\n\e[0m[\e[93m*\e[0m] Updating OneHit script! Please wait... \n"
        git stash
        git stash drop
        git pull
        printf "\n\e[0m[\e[92mi\e[0m] Done! Press [ENTER] to run updated script \n"
        read ener_empty_value
        sudo bash onehit.sh

    else
        printf "\n\e[0m[\e[91m!\e[0m] There is no updates avaiable! \n"
        back_to_menu
    fi

}

banner(){
    clear
    printf "\e[1m\e[38;5;82m"
    cat config/banner.txt
    printf "\e[0m"
}

camera_scan2(){
    banner
    printf "\n\e[0m[\e[92mi\e[0m] Selected target - ${ips[$(($target_number-1))]}"
    printf "\n\e[0m[\e[92mi\e[0m] Scanning with scan time \e[96m$scan_t\e[0m parameter\n"
    printf "\e[0m[\e[93m*\e[0m] Scanning target & gathering informations... \n"
    vendor=$(nmap -T$scan_t $target | awk '/Nmap scan report for / && ip && vendor{print ip,vendor;ip=vendor=""} /Nmap scan report for /{ip=$NF;next} /MAC Address/{sub(/.*\(/,"(");;vendor=$0;next} END{if(ip){print ip,vendor}}' | awk '{print ($2)}' | sed 's/[)(]//g')
    target_service_vendor=$vendor
    printf "\e[0m[\e[92mi\e[0m] Vendor found - \e[92m$target_service_vendor\e[0m\n"
    ports=$(nmap -vv "$target" | grep "Discovered open port" | awk '{print $6":"$4}' | awk -F: '{print $2}' | grep -o '[0-9]\+' | tr '\n' ',' | sed 's/,$/\n/' )
    target_ports=$ports
    printf "\e[0m[\e[92mi\e[0m] Open ports found - \e[92m$ports\e[0m\n"
    printf "\e[0m[\e[92mi\e[0m] Scan completed!\n"
    back_to_menu

}

camera_scan(){
    banner
    printf "\n\e[0m[\e[92mi\e[0m] Scanning with scan time \e[96m$scan_t\e[0m & ports \e[96m$camera_ports\e[0m parameters\n"
    printf "\e[0m[\e[93m*\e[0m] Scanning network for camera's... \n"
    ips=($(nmap -p $camera_ports --open -T$scan_t $gateway | awk '/is up/ {print up}; {gsub (/\(|\)/,""); up = $NF}' | sort))
        if [ ${#ips[@]} -eq "0" ];then 
        printf "\e[0m[\e[91m!\e[0m] No camera's found! \n"
        back_to_menu
    fi

    printf "\e[0m[\e[92mi\e[0m] Found \e[92m%s${#ips[@]}\e[0m targets!\n"
    printf "\n[ Choose target: ]\n"

    i=0

while [ $i -lt ${#ips[@]} ]
do
    printf "\n[$((i+1))] ${ips[$i]}"
    i=$((i+1))

done


    printf "

"

read -p "Choice: " target_number

case $target_number in

([1-${#ips[@]}])
    target="${ips[$(($target_number-1))]}"
    camera_scan2
    ;;
*)
    printf "\n\e[0m[\e[91m!\e[0m] Wrong target selected!"
    back_to_menu
esac

}

settings_menu(){
    banner
    printf "[ Choose option: ]

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

<- Target: \e[38;5;35m$target\e[0m Vendor: \e[38;5;35m$target_service_vendor\e[0m Ports: \e[38;5;35m$target_ports\e[0m ->

[ Choose option: ]

[1] Scan for camera's & select targets
[2] Pwn selected target
[3] Settings
[*] Exit

"
read -p "Choice: " menuchoice

case $menuchoice in
1) camera_scan;;
2) camera_pwn;;
3) settings_menu;;
*) printf "\n\e[0m[\e[93m*\e[0m] Exiting script..."; exit;;
esac

}

check_root
check_internet
check_update
onehit_menu
