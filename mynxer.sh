#!/bin/bash

# set default values

MYNXER="mynexer 1.0b"
NGINX_ALL_VHOSTS="/etc/nginx/sites-available"
NGINX_ENABLED_VHOSTS="/etc/nginx/sites-enabled"
WEB_DIR="/var/www"
SED="which sed"
NGINX="which nginx"
PATTERN="^(([a-zA-Z]|[a-zA-Z][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*([A-Za-z]|[A-Za-z][A-Za-z0-9\-]*[A-Za-z0-9])$";
TEMP=/tmp/answer.$$
MENU_INPUT=/tmp/menu.sh.$$
MENU_OUTPUT=/tmp/output.sh.$$
Magento_REPO="https://GitHub.com/magento/magento2.git"
Prestashop_REPO="https://GitHub.com/PrestaShop/PrestaShop.git"
Laravel_REPO="https://GitHub.com/laravel/laravel.git"
Wordpress_REPO="https://GitHub.com/WordPress/WordPress.git"

sys_check(){

   #check root

    if ( [[ "$(whoami &2>/dev/null)" != 'root' ]] && [[ "$(id -un &2>/dev/null)" != 'root' ]]); then

        root_warning
        tput clear
        exit
    fi

    #check disto

    if [ -f /etc/debian_version ]; then

        #system runining debian based distro and we user has root permissions
        #Let's go to the next dialog

        tput clear

        domain_check
    else

        debian_warning
        tput clear
        exit
    fi



}

### Root previgilies required

root_warning(){

    dialog --screen-center --backtitle "$MYNXER" --title "Error" --colors --msgbox '\Z1Error: You must be root or member of sudoers group to run this script!\Zn' 5 75

}

### We need debian based distro

debian_warning(){

    dialog --screen-center --backtitle "$MYNXER" --title "Error" --colors --msgbox '\Z1This script works best on Debian and Ubuntu Linux\Zn!' 5 55
}


domain_check(){

    dialog --screen-center --backtitle "$MYNXER" --title "Domain Name for virtual Host" --inputbox "Enter your domain name:" 8 40 2> $TEMP

    DOMAIN=`cat $TEMP`
    rm -f $TEMP

    if [[ "$DOMAIN" =~ $PATTERN ]]; then

        dialog --screen-center --backtitle "$MYNXER" --colors --infobox "Please wait... \nCreating virtual host for \n\Z1$DOMAIN" 10 30 ; sleep 3


        # Now we need to copy the virtual host template
        CONFIG="$NGINX_ALL_VHOSTS"/"$DOMAIN".conf
        sed -i "s/DOMAIN/$DOMAIN/g" "$CONFIG"
        sed -i "s#ROOT#$WEB_DIR\/$USERNAME\/public_html#g" "$CONFIG"

        create_user
        exit

    else

        dialog  --screen-center --backtitle "$MYNXER" --colors --infobox "\Z1$DOMAIN\Zn\n is an invalid domain name" 10 30 ; sleep 3
        domain_check
    fi

}

create_user(){


    dialog --screen-center --backtitle "$MYNXER" --title "Username for virtual Host" --inputbox "Please specify the username for this virtual host" 8 40 2> $TEMP

    USERNAME=`cat $TEMP`
    rm -f $TEMP



    if [[ "$USERNAME" =~ $PATTERN ]]; then

        dialog --screen-center --backtitle "$MYNXER" --colors --infobox "Please wait... \nCreating user : \n\Z1$USERNAME" 10 30 ; sleep 3

        adduser --home "$WEB_DIR/$USERNAME" "$USERNAME"

        mkdir -p "$WEB_DIR"/"$USERNAME"/public_html &2>/dev/null

        usermod -a -G www-data "$USERNAME" &2>/dev/null

        # let set an infinite loop
        #

        while true
        do

            ### display main menu ###
            dialog --clear --backtitle "$MYNXER" \
                --title "Project Type" \
                --menu "Please Choose the Project Type" 15 50 4 \
                Magento "Displays date and time" \
                Prestashop "Displays a calendar" \
                Wordpress "Start a text editor" \
                Laravel "Laravel Project" \
                Other "Generic PHP / HTML Project" \
                Exit "Exit to the shell" 2>"${MENU_INPUT}"

            userselection=$(<"${MENU_INPUT}")


            if [ "$userselection" != 'Exit' ]; then

                # Delete possible old/previous config file

                rm -f "$NGINX_ENABLED_VHOSTS"/"$DOMAIN".conf

                cp -f virtual-host-templates/virtual_host_"$userselection".template "$CONFIG"

                # Create symlink
                ln -s "$CONFIG" "$NGINX_ENABLED_VHOSTS"/"$DOMAIN".conf

                ask_clone_question "$userselection" "$userselection"_REPO "$WEB_DIR"/"$USERNAME"/public_html

            else

                echo "Bye"; break;

            fi

        done

        # if temp files exists, destroy`em all!

        [ -f $MENU_OUTPUT ] && rm $MENU_OUTPUT
        [ -f $MENU_INPUT ] && rm $MENU_INPUT

    else

        dialog  --screen-center --backtitle "$MYNXER" --colors --infobox "\Z1$USERNAME\Zn\n is an invalid username" 10 30 ; sleep 3
        create_user
    fi
}

# ask_clone_question Magento git http://git-address/repo /var/www/username/public_html/

ask_clone_question(){

    echo "Would you like to clone $1 project from official GitHub repository to your root folder? y/n"
    read ANSWER

    if ( [[ "$ANSWER" = 'Y' ]] || [[ "$ANSWER" = 'y' ]] ); then

        echo "Please be patient, this may take some time... Project files are cloning from official $1 GitHub repo..."

        #call the install_sources() function
        install_sources "$2" "$3" "$4"

    else

        echo "Would you like to clone the project sources from a personal/private SVN or Git repo? g/s/n ?"
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

install_sources (){

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

        cp -f index-page-templates/index.html.template "$3"/index.php

    fi

    echo "Cloning is finished..."

    sed -i "s/DOMAIN/$DOMAIN/g" "$CONFIG"

    sed -i "s#ROOT#$WEB_DIR\/$USERNAME\/public_html#g" "$CONFIG"

    usermod -a -G www-data "$USERNAME"

    chmod g+rxs "$WEB_DIR"/"$USERNAME"

    chmod 600 "$CONFIG"

    chown -R "$USERNAME":www-data "$WEB_DIR"/"$USERNAME"/public_html

    chmod 0775 -R "$WEB_DIR"/"$USERNAME"/

    /etc/init.d/nginx reload

    /etc/init.d/php5-fpm reload

}



#initialize the script
sys_check
domain_check
create_user

