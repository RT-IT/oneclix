# OneClix 🖱️

A number of scripts for quick setup of various systems on [Vesta Control Panel](https://vestacp.com/). Including a standard(ish) [Wordpress](https://wordpress.org/) installer, a simple domain redirector and a way to host [NodeJS](https://nodejs.org/en/) applications too.

_Ok this probably shouldn't be called OneClix as it's actually a script but oh well..._

## Download

Clone this repo or..

```bash
wget https://github.com/RT-IT/oneclix/archive/master.zip -P ~
unzip ~/master.zip
rm ~/master.zip
```

## Wordpress

### Basic Usage

```bash
cd ~/oneclix-master/wordpress-oneclix/
sudo ./install.sh -d test.com
```

Make sure `test.com`'s DNS is pointing to your server as the script will check. It will check for both `test.com` and `www.test.com` so you might want to add a CName redirect too.
SSL via [Lets Encrypt](https://letsencrypt.org/) is enabled by default, you can change this by supplying `-s NO` flag to the install script.

## Redirect

### Basic Usage

```bash
cd ~/oneclix-master/redirect-oneclix/
sudo ./install.sh -d test.com -t new.com
```

Make sure `test.com`'s DNS is pointing to your server as the script will check. It will check for both `test.com` and `www.test.com` so you might want to add a CName redirect too.
SSL via [Lets Encrypt](https://letsencrypt.org/) is enabled by default, you can change this by supplying `-s NO` flag to the install script.

## NodeJS

TODO: Add details about nodejs-oneclix
