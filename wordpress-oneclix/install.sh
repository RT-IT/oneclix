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
    echo "# Eg. install.sh -d andrewbarber.me       #"
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

echo " "
echo "###########################################"
echo "#              Getting pwgen              #"
echo "###########################################"
sleep 3s
sudo apt-get install pwgen -y >> /dev/null

echo " "
echo "###########################################"
echo "#              Getting unzip              #"
echo "###########################################"
sleep 3s
sudo apt-get install unzip -y >> /dev/null

echo " "
echo "###########################################"
echo "#           Setting up database           #"
echo "###########################################"
sleep 3s

DBNAME=$(echo $DOMAIN | cut -f1 -d".")
DBNAME=$(echo $DBNAME | cut -c1-7)
DBPASS=$(/usr/bin/pwgen 15 1)

/usr/local/vesta/bin/v-list-databases admin > /tmp/db_list.txt

if grep -q "admin_"$DBNAME /tmp/db_list.txt; then
    DBNAME=$DBNAME"_"$(grep -c "admin_"$DBNAME /tmp/db_list.txt);
fi
DBUSER="$DBNAME"

/usr/local/vesta/bin/v-add-database admin $DBNAME $DBUSER $DBPASS


echo " "
echo "###########################################"
echo "#            Getting Wordpress            #"
echo "###########################################"
sleep 3s

rm -rf /tmp/wordpress
cd /tmp
curl -O https://wordpress.org/latest.tar.gz
tar xzvf latest.tar.gz


echo " "
echo "###########################################"
echo "#    Moving Wordpress to its new home     #"
echo "###########################################"
sleep 3s

touch /tmp/wordpress/.htaccess
cp /tmp/wordpress/wp-config-sample.php /tmp/wordpress/wp-config.php
mkdir /tmp/wordpress/wp-content/upgrade
rm -f /home/admin/web/$DOMAIN/public_html/*
cp -a /tmp/wordpress/. /home/admin/web/$DOMAIN/public_html/

echo " "
echo "###########################################"
echo "#          Setting up some Plugins        #"
echo "###########################################"
sleep 3s
mkdir /tmp/plugins/
cd /tmp/plugins/
curl -O https://downloads.wordpress.org/plugin/webp-express.zip
unzip /tmp/plugins/webp-express.zip -d /home/admin/web/$DOMAIN/public_html/wp-content/plugins/

curl -O https://downloads.wordpress.org/plugin/all-in-one-wp-security-and-firewall.zip
unzip /tmp/plugins/all-in-one-wp-security-and-firewall.zip -d /home/admin/web/$DOMAIN/public_html/wp-content/plugins/

curl -O https://downloads.wordpress.org/plugin/google-analytics-for-wordpress.zip
unzip /tmp/plugins/google-analytics-for-wordpress.zip -d /home/admin/web/$DOMAIN/public_html/wp-content/plugins/

curl -O https://downloads.wordpress.org/plugin/rocketchat-livechat.zip
unzip /tmp/plugins/rocketchat-livechat.zip -d /home/admin/web/$DOMAIN/public_html/wp-content/plugins/


echo " "
echo "###########################################"
echo "#          Configuring Wordpress          #"
echo "###########################################"
sleep 3s

chown -R admin:admin /home/admin/web/$DOMAIN/public_html/
chown -R admin:admin /home/admin/web/$DOMAIN/public_html/.htaccess
chown -R admin:admin /home/admin/web/$DOMAIN/public_html/*
chown -R admin:admin /home/admin/web/$DOMAIN/public_html/*/*
chown -R admin:admin /home/admin/web/$DOMAIN/public_html/*/*/*

chmod 755 /home/admin/web/$DOMAIN/public_html/wp-content
chmod 644 /home/admin/web/$DOMAIN/public_html/wp-includes
chmod 644 /home/admin/web/$DOMAIN/public_html/*.php
chmod 644 /home/admin/web/$DOMAIN/public_html/*/*.php
chmod 644 /home/admin/web/$DOMAIN/public_html/*/*/*.php
chmod 444 /home/admin/web/$DOMAIN/public_html/index.php
find /home/admin/web/$DOMAIN/public_html/ -type d -exec chmod 755 {} \;
find /home/admin/web/$DOMAIN/public_html/ -type f -exec chmod 644 {} \;
chmod 0640 /home/admin/web/$DOMAIN/public_html/wp-config.php

sed -i -e 's/database_name_here/admin_'$DBNAME'/g' /home/admin/web/$DOMAIN/public_html/wp-config.php
sed -i -e 's/username_here/admin_'$DBUSER'/g' /home/admin/web/$DOMAIN/public_html/wp-config.php
sed -i -e 's/password_here/'$DBPASS'/g' /home/admin/web/$DOMAIN/public_html/wp-config.php

sed -i -e "s/require_once( ABSPATH . 'wp-settings.php' );/ /g" /home/admin/web/$DOMAIN/public_html/wp-config.php
sed -i -e "s/define( 'AUTH_KEY',         'put your unique phrase here' );/ /g" /home/admin/web/$DOMAIN/public_html/wp-config.php
sed -i -e "s/define( 'SECURE_AUTH_KEY',  'put your unique phrase here' );/ /g" /home/admin/web/$DOMAIN/public_html/wp-config.php
sed -i -e "s/define( 'LOGGED_IN_KEY',    'put your unique phrase here' );/ /g" /home/admin/web/$DOMAIN/public_html/wp-config.php
sed -i -e "s/define( 'NONCE_KEY',        'put your unique phrase here' );/ /g" /home/admin/web/$DOMAIN/public_html/wp-config.php
sed -i -e "s/define( 'AUTH_SALT',        'put your unique phrase here' );/ /g" /home/admin/web/$DOMAIN/public_html/wp-config.php
sed -i -e "s/define( 'SECURE_AUTH_SALT', 'put your unique phrase here' );/ /g" /home/admin/web/$DOMAIN/public_html/wp-config.php
sed -i -e "s/define( 'LOGGED_IN_SALT',   'put your unique phrase here' );/ /g" /home/admin/web/$DOMAIN/public_html/wp-config.php
sed -i -e "s/define( 'NONCE_SALT',       'put your unique phrase here' );/ /g" /home/admin/web/$DOMAIN/public_html/wp-config.php


curl -s https://api.wordpress.org/secret-key/1.1/salt/ >>  /home/admin/web/$DOMAIN/public_html/wp-config.php
echo "define('FS_METHOD', 'direct');" >> /home/admin/web/$DOMAIN/public_html/wp-config.php
echo "@ini_set( 'upload_max_filesize' , '2048M' );@ini_set( 'post_max_size', '2048M');@ini_set( 'memory_limit', '2048M' );@ini_set( 'max_execution_time', '3000' );@ini_set( 'max_input_time', '3000' );" >> /home/admin/web/$DOMAIN/public_html/wp-config.php

echo "require_once( ABSPATH . 'wp-settings.php' );" >> /home/admin/web/$DOMAIN/public_html/wp-config.php

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
echo "#               Cleaning Up               #"
echo "###########################################"
sleep 3s
cd
rm -rf /tmp/wordpress/
rm -rf /tmp/plugins/
rm -rf /tmp/nslookup.txt
rm -rf /tmp/db_list.txt

rm -rf /home/admin/web/$DOMAIN/public_html/wp-content/plugins/hello.php

rm -rf /home/admin/web/$DOMAIN/public_html/wp-content/themes/twentyseventeen/
rm -rf /home/admin/web/$DOMAIN/public_html/wp-content/themes/twentysixteen/

find /home/admin/web/$DOMAIN/public_html -type d -print0 | xargs -0 -I {} find '{}' -type f -print0 | xargs -0 -I {} chmod 0644 {};
find /home/admin/web/$DOMAIN/public_html -type d -print0 | xargs -0 -I {} find '{}' -type f -print0 | xargs -0 -I {} chown admin:admin {};

find /home/admin/web/$DOMAIN/public_html -type d -print0 | xargs -0 -I {} find '{}' -type d -print0 | xargs -0 -I {} chmod 0755 {};
find /home/admin/web/$DOMAIN/public_html -type d -print0 | xargs -0 -I {} find '{}' -type d -print0 | xargs -0 -I {} chown admin:admin {};
chmod 0640 /home/admin/web/$DOMAIN/public_html/wp-config.php

echo " "
echo "###########################################"
echo "#               All complete!             #"
echo "#          You should be good to go       #"
echo "#                   Notes:                #"
echo "###########################################"
echo "#              Database Details           #"
echo "#       DB Name: admin_$DBNAME          #"
echo "#       DB User: admin_$DBUSER          #"
echo "#        DB Pass: $DBPASS          #"
echo "###########################################"
echo "#   Go visit your site in all its glory:  #"
echo "        https://$DOMAIN  "
echo "###########################################"
echo "#          Any issues? Contact:           #"
echo "#  andrew.barber@racetrackpitstop.co.uk   #"
echo "###########################################"


subject="New Website: $DOMAIN"
body="$body               All complete!             "
body="$body          You should be good to go       "
body="$body                   Notes:                "
body="$body              Database Details           "
body="$body       DB Name: admin_$DBNAME          "
body="$body       DB User: admin_$DBUSER          "
body="$body        DB Pass: $DBPASS          "
body="$body   Go visit your site in all its glory:  "
body="$body        https://$DOMAIN  "

email=$(grep admin: /etc/passwd | awk -F':' '{print $5}')

echo -e "Subject:${subject}\n${body}" | sendmail -f "${email}" -t "${email}"

sleep 15s