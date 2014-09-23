#!/bin/bash

# set default values
tput clear

if  [ -f  /etc/mynxer.conf ]; then
    source /etc/mynxer.conf

    #initialize the script
    sys_check


else
    source mynxer.conf
    #check installation
    setup_warning
    exit

fi

#installation required

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
                Magento "Magento Project" \
                Prestashop "Prestashop Project" \
                Wordpress "Wordpress Project" \
                Laravel "Laravel Project" \
                Other "Generic PHP / HTML Project" \
                Exit "Exit to the shell" 2>"${MENU_INPUT}"

            userselection=$(<"${MENU_INPUT}")


            if [ "$userselection" = 'Exit' ]; then

                echo "Bye"; break;

            elif [ "$userselection" = 'Magento' ]; then

                CONFIG="$NGINX_ALL_VHOSTS"/"$DOMAIN".conf

                # Delete possible old/previous config file

                rm -f "$NGINX_ENABLED_VHOSTS"/"$DOMAIN".conf

                cp -f /usr/share/mynxer/virtual-host-templates/virtual_host_"$userselection".template "$CONFIG"
                # Now we need to copy the virtual host template

                sed -i "s/DOMAIN/$DOMAIN/g" "$CONFIG"

                sed -i "s#ROOT#$WEB_DIR\/$USERNAME\/public_html#g" "$CONFIG"


                # Create symlink

                ln -s "$CONFIG" "$NGINX_ENABLED_VHOSTS"/"$DOMAIN".conf


                THE_REPO="https://github.com/magento/magento2.git"

                ask_clone_question "$userselection" "$THE_REPO" "$WEB_DIR"/"$USERNAME"/public_html


            elif [ "$userselection" = 'Prestashop' ]; then


                CONFIG="$NGINX_ALL_VHOSTS"/"$DOMAIN".conf

                # Delete possible old/previous config file

                rm -f "$NGINX_ENABLED_VHOSTS"/"$DOMAIN".conf

                cp -f /usr/share/mynxer/virtual-host-templates/virtual_host_"$userselection".template "$CONFIG"
                # Now we need to copy the virtual host template

                sed -i "s/DOMAIN/$DOMAIN/g" "$CONFIG"

                sed -i "s#ROOT#$WEB_DIR\/$USERNAME\/public_html#g" "$CONFIG"


                # Create symlink

                ln -s "$CONFIG" "$NGINX_ENABLED_VHOSTS"/"$DOMAIN".conf


                THE_REPO="https://github.com/PrestaShop/PrestaShop.git"

                ask_clone_question "$userselection" "$THE_REPO" "$WEB_DIR"/"$USERNAME"/public_html


            elif [ "$userselection" = 'Laravel' ]; then

                CONFIG="$NGINX_ALL_VHOSTS"/"$DOMAIN".conf

                # Delete possible old/previous config file

                rm -f "$NGINX_ENABLED_VHOSTS"/"$DOMAIN".conf

                cp -f /usr/share/mynxer/virtual-host-templates/virtual_host_"$userselection".template "$CONFIG"
                # Now we need to copy the virtual host template

                sed -i "s/DOMAIN/$DOMAIN/g" "$CONFIG"

                sed -i "s#ROOT#$WEB_DIR\/$USERNAME\/public_html#g" "$CONFIG"


                # Create symlink

                ln -s "$CONFIG" "$NGINX_ENABLED_VHOSTS"/"$DOMAIN".conf

                THE_REPO="https://github.com/laravel/laravel.git"

                ask_clone_question "$userselection" "$THE_REPO" "$WEB_DIR"/"$USERNAME"/public_html


            elif [ "$userselection" = 'Wordpress' ]; then

                CONFIG="$NGINX_ALL_VHOSTS"/"$DOMAIN".conf

                # Delete possible old/previous config file

                rm -f "$NGINX_ENABLED_VHOSTS"/"$DOMAIN".conf

                cp -f /usr/share/mynxer/virtual-host-templates/virtual_host_"$userselection".template "$CONFIG"
                # Now we need to copy the virtual host template

                sed -i "s/DOMAIN/$DOMAIN/g" "$CONFIG"

                sed -i "s#ROOT#$WEB_DIR\/$USERNAME\/public_html#g" "$CONFIG"


                # Create symlink

                ln -s "$CONFIG" "$NGINX_ENABLED_VHOSTS"/"$DOMAIN".conf

                THE_REPO="https://github.com/WordPress/WordPress.git"

                ask_clone_question "$userselection" "$THE_REPO" "$WEB_DIR"/"$USERNAME"/public_html


            fi


            # if temp files exists, destroy`em all!

            [ -f $MENU_OUTPUT ] && rm $MENU_OUTPUT
            [ -f $MENU_INPUT ] && rm $MENU_INPUT


        done
    else

        dialog  --screen-center --backtitle "$MYNXER" --colors --infobox "\Z1$USERNAME\Zn\n is an invalid username" 10 30 ; sleep 3
        create_user
    fi

    exit
}

# ask_clone_question Magento git http://git-address/repo /var/www/username/public_html/

ask_clone_question(){

    # let set an infinite loop
    #

    while true
    do

        if [ "$1" != 'Other' ]; then

            ### display main menu ###

            dialog --clear --backtitle "$MYNXER" \
                --title "Project Type" \
                --menu "Please Choose the Project Type" 15 50 4 \
                Github "Clone $1 project from official GitHub repository" \
                SVN "Clone $1 project from a personal / private SVN repository" \
                Git "Clone $1 project from a personal / private Git repository" \
                Exit "Exit to the shell" 2>"${MENU_INPUT}"
        else
            ### display main menu ###

            dialog --clear --backtitle "$MYNXER" \
                --title "Project Type" \
                --menu "Please Choose the Project Type" 15 50 4 \
                SVN "Clone $1 project from a personal / private SVN repository" \
                Git "Clone $1 project from a personal / private Git repository" \
                Exit "Exit to the shell" 2>"${MENU_INPUT}"

        fi

        userselection=$(<"${MENU_INPUT}")


        if [ "$userselection" == 'Github' ]; then

            CONFIG="$NGINX_ALL_VHOSTS"/"$DOMAIN".conf

            # Delete possible old/previous config file

            rm -f "$NGINX_ENABLED_VHOSTS"/"$DOMAIN".conf

            cp -f /usr/share/mynxer/virtual-host-templates/virtual_host_"$userselection".template "$CONFIG"
            # Now we need to copy the virtual host template

            sed -i "s/DOMAIN/$DOMAIN/g" "$CONFIG"

            sed -i "s#ROOT#$WEB_DIR\/$USERNAME\/public_html#g" "$CONFIG"

            # Create symlink

            ln -s "$CONFIG" "$NGINX_ENABLED_VHOSTS"/"$DOMAIN".conf

            install_sources "$userselection" "$2" "$WEB_DIR"/"$USERNAME"/public_html

        elif ( [[ "$userselection" = 'SVN' ]] || [[ "$userselection" = 'Git' ]] ); then

            ask_repo_address $userselection "$WEB_DIR"/"$USERNAME"/public_html

        else

            tput clear; echo "Bye"; break;

        fi

    done

    # if temp files exists, destroy`em all!

    [ -f $MENU_OUTPUT ] && rm $MENU_OUTPUT
    [ -f $MENU_INPUT ] && rm $MENU_INPUT

    exit

}
ask_repo_address(){

    tput clear

    dialog --screen-center --backtitle "$MYNXER" --title "Personal / Private $1 URL" --inputbox "Enter your $1 repo URL below:" 8 40 2> $TEMP

    REPO_URL=`cat $TEMP`

    rm -f $TEMP

    install_sources $1 $REPO_URL $2

    exit
}

# install_sources git http://git-address/repo /var/www/username/public_html/
# install_sources svn http://svn-address/repo /var/www/username/public_html/

install_sources (){

    tput clear

    if ( [[ "$1" = 'Github' ]] || [[ "$1" = 'Git' ]] ); then

        git clone "$2" "$3"/git/

        cp -rf "$3"/git/* "$3"/

        rm -rf "$3"/git/

        echo "Done"

    elif [[ "$1" = 'SVN' ]]; then

        svn co "$2" "$3"/svn/

        cp -rf "$3"/svn/* "$3"/

        rm -rf "$3"/svn/

        echo "Done"
    else

        cp -f /usr/share/mynxer/index-page-templates/index.html.template "$3"/index.php

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

    exit
}
sys_check
domain_check

