#!/bin/bash

export USERNAME=`awk -F: '{ if ($3 == '$UID') { print $1 } }' /etc/passwd`
export COMPOSER_CACHE_DIR="/tmp/$USERNAME/composer"

if [ -n "$XDEBUG" ];
then
    inifile="/usr/local/etc/php/conf.d/pecl-xdebug.ini"
    extfile="$(find /usr/local/lib/php/extensions/ -name xdebug.so)";
    remote_port="${XDEBUG_REMOTE_PORT:-9000}";
    remote_os="${XDEBUG_REMOTE_OS:-linux}";
    idekey="${XDEBUG_IDEKEY:-xdbg}";

    if [ -f "$extfile" ] && [ ! -f "$inifile" ];
    then
        {
            echo "[Xdebug]";
            echo "zend_extension=${extfile}";
            echo "xdebug.idekey=${idekey}";
            echo "xdebug.remote_enable=1";
            echo "xdebug.remote_autostart=1";
            echo "xdebug.remote_port=${remote_port}";
        } > $inifile;

        if [ $remote_os = "macos" ] || [ $remote_os = "windows"];
        then
            {
                echo "xdebug.remote_connect_back=0";
                echo "xdebug.remote_host=host.docker.internal";
            } >> $inifile;
        else
            {
                echo "xdebug.remote_connect_back=1";
            } >> $inifile;
        fi

    fi

    unset extfile remote_port idekey;
fi

if [ "$UID" = "0" ];
then
    if [[ "$WWW_DATA_ID" =~ ^([0-9][0-9]*):([0-9][0-9]*)$ ]];
    then
        usermod -u "${BASH_REMATCH[1]}" www-data
        groupmod -g "${BASH_REMATCH[2]}" www-data
        unset "WWW_DATA_ID"
    fi

    if [[ "$WWW_DATA_UID" =~ ^([0-9][0-9]*)$ ]];
    then
        usermod -u "${BASH_REMATCH[1]}" www-data
        unset "WWW_DATA_UID"
    fi

    if [[ "$WWW_DATA_GID" =~ ^([0-9][0-9]*)$ ]];
    then
        groupmod -g "${BASH_REMATCH[1]}" www-data
        unset "WWW_DATA_GID"
    fi
fi

exec "$@"
