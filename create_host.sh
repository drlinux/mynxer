#!/bin/bash

if ( [[ "$(whoami &2>/dev/null)" != 'root' ]] && [[ "$(id -un &2>/dev/null)" != 'root' ]]); then
    echo "Error: You must be root or sudoer to run this script."
    exit 1;
fi
clear
CURRENT_DIR="dirname $0"

# ask_clone_question Magento git http://git-address/repo /var/www/username/public_html/
function ask_clone_question()
{

    echo "Would you like to clone $1 project from official GitHub repository to your root folder? y/n"
    read ANSWER

    if ( [[ "$ANSWER" = 'Y' ]] || [[ "$ANSWER" = 'y' ]] ); then

        echo "Please be patient, this may take some time... Project files are cloning from official $1 GitHub repo..."

        #call the install_sources() function
        install_sources "$2" "$3" "$4"

    else

        echo "Do you want to clone the project sources from a personal/private SVN or Git repo? g/s/n ?"
        read SCM_ANSWER

        if ( [[ "$SCM_ANSWER" = 'g' ]] || [[ "$SCM_ANSWER" = 'G' ]] || [[ "$SCM_ANSWER" = 's' ]] || [[ "$SCM_ANSWER" = 'S' ]] ); then

            echo "Please give url for the repo"
            read REPO_URL

            echo "Please be patient, this may take some time... Project files are cloning from $REPO_URL ..."

            #call the install_sources() function
            if ( [[ "$SCM_ANSWER" = 'g' ]] || [[ "$SCM_ANSWER" = 'G' ]]); then

                install_sources git "$REPO_URL" "$4"

            elif ( [[ "$SCM_ANSWER" = 's' ]] || [[ "$SCM_ANSWER" = 'S' ]]); then
                install_sources svn "$REPO_URL" "$4"

            else
                install_sources other other "$4"
            fi
        fi

    fi
}

# install_sources git http://git-address/repo /var/www/username/public_html/
# install_sources svn http://svn-address/repo /var/www/username/public_html/
function install_sources ()
{

    if [[ "$1" == 'git' ]]; then

        git clone "$2" "$3"/git

        cp -rf "$3"/git/* "$3"/

        rm -rf "$3"/git/

        echo "Done"

    elif [[ "$1" = 'svn' ]]; then

        svn co "$2" "$3"/svn/

        cp -rf "$3"/svn/* "$3"/

        rm -rf "$3"/git/

        echo "Done"
    else

        cp -f /index-page-templates/index.html.template "$3"/index.php

    fi

    echo "Cloning is finished..."
}

# Check the distribution
echo "Checking distribution..."
if [ -f /etc/debian_version ];
then echo "Supported distribution found"
    echo "System is running on Debian Linux"
else echo -e "Failed...........\nThis script works best on Debian and Ubuntu Linux!\n"
    exit 1
fi

# Check existence of which-binary package
echo "Checking for which... "
if ( test -f /usr/bin/which ) || ( test -f /bin/which ) || ( test -f /sbin/which ) || ( test -f /usr/sbin/which );
then echo "OK";
else printf "Failed...........\nPlease install which-binary!"
    exit 1
fi

NGINX_ALL_VHOSTS="/etc/nginx/sites-available"
NGINX_ENABLED_VHOSTS="/etc/nginx/sites-enabled"
WEB_DIR="/var/www"
SED="which sed"
NGINX="which nginx"

if [ -z "$1" ]; then
    echo "Error: Domain name is empty"
    exit 1
fi
DOMAIN=$1

# check the domain is valid!
PATTERN="^(([a-zA-Z]|[a-zA-Z][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*([A-Za-z]|[A-Za-z][A-Za-z0-9\-]*[A-Za-z0-9])$";
if [[ "$DOMAIN" =~ $PATTERN ]]; then
    #DOMAIN="echo $DOMAIN | tr '[A-Z]' '[a-z]'"
    echo "Creating hosting for: $DOMAIN"
else
    echo "Error: Invalid domain name"
    exit 1;
fi

# Create a new user!
echo "Please specify the username for this site?"
read USERNAME
adduser --home "$WEB_DIR/$USERNAME" "$USERNAME"

mkdir -p /var/www/"$USERNAME"/public_html

# Now we need to copy the virtual host template
CONFIG="$NGINX_ALL_VHOSTS"/"$DOMAIN".conf

clear

OPTIONS="Magento Prestashop Wordpress Laravel Other"

select PROJECT_TYPE in $OPTIONS; do

    echo "$PROJECT_TYPE project selected..."

    if [[ "$PROJECT_TYPE" = 'Magento' ]]; then

        # Delete possible old/previous config file
        rm -f "$NGINX_ENABLED_VHOSTS"/"$DOMAIN".conf

        cp -f virtual-host-templates/virtual_host_magento.template "$CONFIG"

        # Create symlink
        ln -s "$CONFIG" "$NGINX_ENABLED_VHOSTS"/"$DOMAIN".conf

        ask_clone_question Magento git https://GitHub.com/magento/magento2.git "$WEB_DIR"/"$USERNAME"/public_html
        break;

    elif [[ "$PROJECT_TYPE" = 'Prestashop' ]]; then

        # Delete possible old/previous config file
        rm -f "$NGINX_ENABLED_VHOSTS"/"$DOMAIN".conf

        cp -f "virtual-host-templates/virtual_host_presta.template" "$CONFIG"

        # Create symlink
        ln -s "$CONFIG" "$NGINX_ENABLED_VHOSTS"/"$DOMAIN".conf

        ask_clone_question Prestashop git https://GitHub.com/PrestaShop/PrestaShop.git "$WEB_DIR/$USERNAME"/public_html
        break;

    elif [[ "$PROJECT_TYPE" = 'WordPress' ]]; then

        # Delete possible old/previous config file
        rm -f "$NGINX_ENABLED_VHOSTS"/"$DOMAIN".conf

        cp -f "virtual-host-templates/virtual_host_wordpress.template" "$CONFIG"

        # Create symlink
        ln -s "$CONFIG" "$NGINX_ENABLED_VHOSTS"/"$DOMAIN".conf

        ask_clone_question Wordpress git https://GitHub.com/WordPress/WordPress.git "$WEB_DIR/$USERNAME"/public_html
        break;

    elif [[ "$PROJECT_TYPE" = 'Laravel' ]]; then

        # Delete possible old/previous config file
        rm -f "$NGINX_ENABLED_VHOSTS"/"$DOMAIN".conf

        cp -f "virtual-host-templates/virtual_host_laravel.template" "$CONFIG"

        # Create symlink
        ln -s "$CONFIG" "$NGINX_ENABLED_VHOSTS"/"$DOMAIN".conf


        ask_clone_question Laravel git https://GitHub.com/laravel/laravel.git "$WEB_DIR/$USERNAME/public_html"
        break;

    elif [[ "$PROJECT_TYPE" = 'Other' ]]; then

        echo "Simple PHP/HTML project selected..."

        install_sources other other "$WEB_DIR/$USERNAME/public_html"

        # Delete possible old/previous config file
        rm -f "$NGINX_ENABLED_VHOSTS"/"$DOMAIN".conf

        cp -f "virtual-host-templates/virtual_host.template" "$CONFIG"
        # Create symlink
        ln -s "$CONFIG" "$NGINX_ENABLED_VHOSTS"/"$DOMAIN".conf


        $SED -i "s/SITE/$DOMAIN/g" "$WEB_DIR/$USERNAME/public_html/index.php"
        break;

    else
        echo "WTF?"
        exit 1
    fi
done


sed -i "s/DOMAIN/$DOMAIN/g" "$CONFIG"
sed -i "s#ROOT#$WEB_DIR\/$USERNAME\/public_html#g" "$CONFIG"

usermod -a -G www-data "$USERNAME"
chmod g+rxs "$WEB_DIR"/"$USERNAME"
chmod 600 "$CONFIG"


/etc/init.d/nginx reload

chown -R "$USERNAME":www-data "$WEB_DIR"/"$USERNAME"/public_html
chmod 0775 -R "$WEB_DIR"/"$USERNAME"/
echo -e "\nSite creation is done"
echo "--------------------------"
echo "Host : $HOSTNAME"
echo "URL  : $DOMAIN"
echo "User : $USERNAME"
echo "--------------------------"
exit 0;
