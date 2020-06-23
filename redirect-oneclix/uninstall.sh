#!/bin/bash

## Set your vesta panel user below..
USER="admin"

clear
echo "###########################################"
echo "#     Welcome to the wordpress oneclix!   #"
echo "###########################################"
echo "#          Any issues? Contact:           #"
echo "#    andrew.barber@rt-itservices.co.uk    #"
echo "###########################################"


sleep 10s

SSL="YES"

while getopts d:s:ms:e option
do
    case "${option}"
        in
        d) DOMAIN=${OPTARG,,};;
        s) SSL=${OPTARG^^};;
    esac
done

if [ -z "$DOMAIN" ]; then
    echo " "
    echo "###########################################"
    echo "# Pass a command flag with the domain name#"
    echo "# Eg. uninstall.sh -d andrewbarber.me     #"
    echo "#   Exiting now... please try again!      #"
    echo "###########################################"
    exit
fi
if [ "$EUID" -ne 0 ]; then
    echo " "
    echo "###########################################"
    echo "#          Please run with sudo           #"
    echo "#   Exiting now... please try again!      #"
    echo "###########################################"
    exit
fi


echo " "
echo "###########################################"
echo "#        Removing domain and files        #"
echo "###########################################"
sleep 3s

/usr/local/vesta/bin/v-delete-domain $USER $DOMAIN



echo " "
echo "###########################################"
echo "#                  All gone!              #"
echo "###########################################"
echo "#          Any issues? Contact:           #"
echo "#    andrew.barber@rt-itservices.co.uk    #"
echo "###########################################"


subject="Website Removed: $DOMAIN"
body="$body               Website removed           "
body="$body          $DOMAIN       "

email=$(grep $USER: /etc/passwd | awk -F':' '{print $5}')

echo -e "Subject:${subject}\n${body}" | sendmail -f "${email}" -t "${email}"

sleep 15s