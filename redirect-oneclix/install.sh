#!/bin/bash

clear
echo "###########################################"
echo "#     Welcome to the wordpress oneclix!   #"
echo "###########################################"
echo "#          Any issues? Contact:           #"
echo "#     helpdesk@racetrackpitstop.co.uk     #"
echo "###########################################"


sleep 10s

SSL="YES"

while getopts d:s:t option
do
    case "${option}"
        in
        d) DOMAIN=${OPTARG,,};;
        s) SSL=${OPTARG^^};;
        t) DOMAINTO=${OPTARG,,};;
    esac
done

if [ -z "$DOMAIN" ]; then
    echo " "
    echo "###########################################"
    echo "# Pass a command flag with the domain name#"
    echo "Eg. install.sh -d andrewbarber.me -t andrewbarber.com"
    echo "#   Exiting now... please try again!      #"
    echo "###########################################"
    exit
fi
if [ -z "$DOMAINTO" ]; then
    echo " "
    echo "###########################################"
    echo "# Pass a command flag with the domain name#"
    echo "Eg. install.sh -d andrewbarber.me -t andrewbarber.com"
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

DOMAIN="$( echo "$DOMAIN" | sed -e 's#^http://##; s#^https://##' )"
DOMAINTO="$( echo "$DOMAINTO" | sed -e 's#^http://##; s#^https://##' )"

MYIP=$(/sbin/ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p')

/usr/bin/nslookup $DOMAIN > /tmp/nslookup.txt

if ! grep -q $MYIP /tmp/nslookup.txt; then
    echo " "
    echo "###########################################"
    echo "# $DOMAIN #"
    echo "#            is not pointing to           #"
    echo "#              $MYIP             #"
    echo "#   Exiting now... please try again!      #"
    echo "###########################################"
    exit
fi

/usr/bin/nslookup "www."$DOMAIN > /tmp/nslookup.txt

if ! grep -q $MYIP /tmp/nslookup.txt; then
    echo " "
    echo "###########################################"
    echo "# www.$DOMAIN #"
    echo "#            is not pointing to           #"
    echo "#              $MYIP             #"
    echo "#   Exiting now... please try again!      #"
    echo "###########################################"
    exit
fi

echo " "
echo "###########################################"
echo "#            Setting up domain            #"
echo "###########################################"
sleep 3s

/usr/local/vesta/bin/v-add-domain admin $DOMAIN

if [ $SSL = "YES" ]; then
    
    echo " "
    echo "###########################################"
    echo "#           Setting up SSL/HTTPS          #"
    echo "###########################################"
    sleep 3s
    cd /usr/local/vesta/data/templates/web
    curl -O http://c.vestacp.com/0.9.8/rhel/force-https/nginx.tar.gz
    tar -xzvf nginx.tar.gz
    rm -f nginx.tar.gz
    
    /usr/local/vesta/bin/v-add-letsencrypt-domain admin $DOMAIN
    /usr/local/vesta/bin/v-change-web-domain-proxy-tpl admin $DOMAIN force-https
    
fi

echo " "
echo "###########################################"
echo "#           Setting up redirect           #"
echo "###########################################"
sleep 3s
echo "RewriteEngine on" > /home/admin/web/$DOMAIN/public_html/.htaccess
echo "RewriteCond %{HTTP_HOST} ^$DOMAIN [NC,OR]" >> /home/admin/web/$DOMAIN/public_html/.htaccess
echo "RewriteCond %{HTTP_HOST} ^www.$DOMAIN [NC]" >> /home/admin/web/$DOMAIN/public_html/.htaccess
echo "RewriteRule ^(.*)$ https://$DOMAINTO/$1 [L,R=301,NC]" >> /home/admin/web/$DOMAIN/public_html/.htaccess


echo " "
echo "###########################################"
echo "#               All complete!             #"
echo "#          You should be good to go       #"
echo "#                   Notes:                #"
echo "###########################################"
echo "#   Go visit your site in all its glory:  #"
echo "        https://$DOMAIN  "
echo "###########################################"
echo "#          Any issues? Contact:           #"
echo "#  andrew.barber@racetrackpitstop.co.uk   #"
echo "###########################################"