#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   printf "\n\e[0m[\e[91m!\e[0m] This script must be run as root! Aborting...\n" 
   exit 1
fi

oneshot_setup(){

if [ ! -d $(pwd)/OneShot ]; then
   printf "\n\e[0m[\e[92mi\e[0m] OneShot directory not found! Cloning it... \n"
   git clone https://github.com/drygdryg/OneShot
else
   printf "\n\e[0m[\e[92mi\e[0m] OneShot directory found! \n"
fi

printf "\n\e[0m[\e[92mi\e[0m] OneShot setup done! \n"

}

printf "
<---------- ONEHIT INSTALLER ---------->

"
apt update

info='\n\e[0m[\e[92mi\e[0m] Installing requirement...\n'

command -v pixiewps >/dev/null 2>&1 || { printf >&2 "\e[0m$info\n "; apt-get install pixiewps -y; }
command -v iw >/dev/null 2>&1 || { printf >&2 "\e[0m$info\n "; apt-get install iw -y; }
command -v python3 >/dev/null 2>&1 || { printf >&2 "\e[0m$info\n "; apt-get install python3 -y; }
command -v wpa_supplicant >/dev/null 2>&1 || { printf >&2 "\e[0m$info\n "; apt-get install wpasupplicant -y; }
command -v git >/dev/null 2>&1 || { printf >&2 "\e[0m$info\n "; apt-get install git -y; }

oneshot_setup

printf "\n\e[0m[\e[92mi\e[0m] OneHit installation done! \n"
