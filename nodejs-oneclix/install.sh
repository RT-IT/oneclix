#!/bin/bash

clear
echo "###########################################"
echo "#     Welcome to the wordpress oneclix!   #"
echo "###########################################"
echo "#          Any issues? Contact:           #"
echo "#    andrew.barber@rt-itservices.co.uk    #"
echo "###########################################"
sleep 10s

SSL="YES"

while getopts d:p:s option
    do
    case "${option}"
        in
            d) DOMAIN=${OPTARG,,};;
            p) PORT=${OPTARG^^};;
            s) SSL=${OPTARG^^};;
    esac
done

if [ -z "$DOMAIN" ]; then
        echo " "
        echo "###########################################"
        echo "# Pass a command flag with the domain name#"
        echo "#    Eg. install.sh -d andrewbarber.me    #"
        echo "#   Exiting now... please try again!      #"
        echo "###########################################"
        exit
fi
if [ -z "$PORT" ]; then
        echo " "
        echo "###########################################"
        echo "#  Pass a port flag with the domain name  #"
        echo "#         Eg. install.sh -p 8003          #"
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

FILENAME="/usr/local/vesta/data/templates/web/nginx/node-p$PORT.tpl"
SFILENAME="/usr/local/vesta/data/templates/web/nginx/node-p$PORT.stpl"

if test -f "$FILENAME"; then
        echo " "
        echo "###########################################"
        echo "#          Port already in use            #"
        echo "#          might need to remove           #"
        echo "$FILENAME"
        echo "#                  or                     #"
        echo "$SFILENAME"
        echo "#   Exiting now... please try again!      #"
        echo "###########################################"
        exit
fi



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

    /usr/local/vesta/bin/v-add-letsencrypt-domain admin $DOMAIN
    /usr/local/vesta/bin/v-change-web-domain-proxy-tpl admin $DOMAIN force-https

fi

        echo " "
        echo "###########################################"
        echo "#                 Creating...             #"
        echo "$FILENAME"
        echo "###########################################"
            sleep 3s

touch $FILENAME

echo "server {" >> $FILENAME
echo "    listen      %ip%:%proxy_port%;" >> $FILENAME
echo "    server_name %domain_idn% %alias_idn%;" >> $FILENAME
echo "    location / {" >> $FILENAME
echo "        rewrite ^(.*) https://%domain_idn%\$1 permanent;" >> $FILENAME
echo "    }" >> $FILENAME
echo "include %home%/%user%/conf/web/*nginx.%domain_idn%.conf_letsencrypt;" >> $FILENAME
echo "}" >> $FILENAME

#echo "server {" >> $FILENAME
#echo "    listen      %ip%:%proxy_port%;" >> $FILENAME
#echo "    server_name %domain_idn% %alias_idn%;" >> $FILENAME
#echo "    error_log  /var/log/%web_system%/domains/%domain%.error.log error;" >> $FILENAME
#echo "    root %sdocroot%;" >> $FILENAME
#echo "    index index.html;" >> $FILENAME
#echo "    location / {" >> $FILENAME
#echo "        proxy_pass      http://127.0.0.1:$PORT;" >> $FILENAME
#echo "        proxy_http_version 1.1;" >> $FILENAME
#echo "        proxy_set_header Upgrade \$http_upgrade;" >> $FILENAME
#echo "        proxy_set_header Connection 'upgrade';" >> $FILENAME
#echo "        proxy_set_header Host \$host;" >> $FILENAME
#echo "        proxy_cache_bypass \$http_upgrade;" >> $FILENAME
#echo "        try_files \$uri \$uri/ @rewrites;" >> $FILENAME
#echo "        location ~* ^.+\.(%proxy_extentions%)$ {" >> $FILENAME
#echo "            access_log     /var/log/%web_system%/domains/%domain%.log combined;" >> $FILENAME
#echo "            access_log     /var/log/%web_system%/domains/%domain%.bytes bytes;" >> $FILENAME
#echo "            expires        max;" >> $FILENAME
#echo "        }" >> $FILENAME
#echo "    }" >> $FILENAME
#echo "    location @rewrites {" >> $FILENAME
#echo "      rewrite ^(.+)$ /index.html last;" >> $FILENAME
#echo "    }" >> $FILENAME
#echo "    location /error/ {" >> $FILENAME
#echo "        alias   %home%/%user%/web/%domain%/document_errors/;" >> $FILENAME
#echo "    }" >> $FILENAME
#echo "    location ~ /\.ht    {return 404;}" >> $FILENAME
#echo "    location ~ /\.svn/  {return 404;}" >> $FILENAME
#echo "    location ~ /\.git/  {return 404;}" >> $FILENAME
#echo "    location ~ /\.hg/   {return 404;}" >> $FILENAME
#echo "    location ~ /\.bzr/  {return 404;}" >> $FILENAME
#echo "    include %home%/%user%/conf/web/*nginx.%domain_idn%.conf_letsencrypt;" >> $FILENAME
#echo "    include %home%/%user%/conf/web/s%proxy_system%.%domain%.conf*;" >> $FILENAME
#echo "}" >> $FILENAME


        echo " "
        echo "###########################################"
        echo "#                 Creating...             #"
        echo "$SFILENAME"
        echo "###########################################"
touch $SFILENAME



echo "server {" >> $SFILENAME
echo "    listen      %ip%:%proxy_ssl_port%;" >> $SFILENAME
echo "    server_name %domain_idn% %alias_idn%;" >> $SFILENAME
echo "    ssl         on;" >> $SFILENAME
echo "    ssl_certificate      %ssl_pem%;" >> $SFILENAME
echo "    ssl_certificate_key  %ssl_key%;" >> $SFILENAME
echo "    error_log  /var/log/%web_system%/domains/%domain%.error.log error;" >> $SFILENAME
echo "    ssl_protocols TLSv1 TLSv1.1 TLSv1.2;" >> $SFILENAME
echo "    ssl_prefer_server_ciphers on;" >> $SFILENAME
echo "    ssl_ciphers 'EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH';" >> $SFILENAME
echo "    location / {" >> $SFILENAME
echo "        proxy_pass      http://127.0.0.1:$PORT;" >> $SFILENAME
echo "        proxy_http_version 1.1;" >> $SFILENAME
echo "        proxy_set_header Upgrade \$http_upgrade;" >> $SFILENAME
echo "        proxy_set_header Connection 'upgrade';" >> $SFILENAME
echo "        proxy_set_header Host \$host;" >> $SFILENAME
echo "        proxy_cache_bypass \$http_upgrade;" >> $SFILENAME
echo "    }" >> $SFILENAME
echo "    location @rewrites {" >> $SFILENAME
echo "      rewrite ^(.+)$ /index.html last;" >> $SFILENAME
echo "    }" >> $SFILENAME
echo "    location /error/ {" >> $SFILENAME
echo "        alias   %home%/%user%/web/%domain%/document_errors/;" >> $SFILENAME
echo "    }" >> $SFILENAME
echo "    location ~ /\.ht    {return 404;}" >> $SFILENAME
echo "    location ~ /\.svn/  {return 404;}" >> $SFILENAME
echo "    location ~ /\.git/  {return 404;}" >> $SFILENAME
echo "    location ~ /\.hg/   {return 404;}" >> $SFILENAME
echo "    location ~ /\.bzr/  {return 404;}" >> $SFILENAME
echo "    include %home%/%user%/conf/web/*nginx.%domain_idn%.conf_letsencrypt;" >> $SFILENAME
echo "    include %home%/%user%/conf/web/s%proxy_system%.%domain%.conf*;" >> $SFILENAME
echo "}" >> $SFILENAME


        echo " "
        echo "###########################################"
        echo "#            Setting template             #"
        echo "###########################################"
        /usr/local/vesta/bin/v-change-web-domain-proxy-tpl admin $DOMAIN node-p$PORT restart



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


        echo " "
echo "###########################################"
echo "#               All complete!             #"
echo "#          You should be good to go       #"
echo "###########################################"

sleep 15s