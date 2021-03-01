#!/bin/bash

# Author: Tasos Latsas
# Modified: Joel Hernández

# spinner.sh
#
# Display an awesome 'spinner' while running your long shell commands
#
# Do *NOT* call _spinner function directly.
# Use {start,stop}_spinner wrapper functions

# usage:
#   1. source this script in your's
#   2. start the spinner:
#       start_spinner [display-message-here]
#   3. run your command
#   4. stop the spinner:
#       stop_spinner [your command's exit status]
#
function _spinner() {
    # $1 start/stop
    #
    # on start: $2 display message
    # on stop : $2 process exit status
    #           $3 spinner function pid (supplied from stop_spinner)

    local on_success="DONE"
    local on_fail="FAIL"
    local white="\e[1;37m"
    local green="\e[1;32m"
    local red="\e[1;31m"
    local nc="\e[0m"
    
    case $1 in
        start)
            printf "   ⣾  ${2}"
            # start spinner
            i=1
            sp='⣷⣯⣟⡿⢿⣻⣽⣾'
            delay=${SPINNER_DELAY:-0.05}

            while :
            do
                j=1
                while [ $j -le $((${#2} + 3)) ]
                do
                    ((j++))
                    printf "\b"
                done

                printf "${sp:i++%${#sp}:1}  "
                echo -ne ${2}
                sleep $delay
            done
            ;;
        stop)
            if [[ -z ${3} ]]; then
                echo "spinner is not running.."
                exit 1
            fi

            kill $3 > /dev/null 2>&1

            let column=$(tput cols)
            j=1
            while [ $j -le $column ]
            do
                ((j++))
                printf "\b"
            done

            # inform the user uppon success or failure
            echo -en "   "
            if [[ $2 -eq 0 ]]; then
                echo -en "${5}"
            else
                echo -en "❌"
            fi
            echo -e " ${4}"
            ;;
        *)
            echo "invalid argument, try {start/stop}"
            exit 1
            ;;
    esac
}

message=""

function start_spinner {
    # $1 : msg to display
    message=`echo ${1}`
    _spinner "start" "${1}" &
    # set global spinner pid
    _sp_pid=$!
    disown
}

function stop_spinner {
    # $1 : command exit status
    _spinner "stop" $1 $_sp_pid "$message" "${2}"
    unset _sp_pid
}