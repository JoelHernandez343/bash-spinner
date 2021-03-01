#!/bin/bash
source "$(pwd)/spinner.sh"

# test success
start_spinner 'Subiendo archivos de Tomcat'
sleep 2
stop_spinner $? '🥺'

# test fail
start_spinner 'Configurando mysql'
# use sleep to give spinner time to fork and run
# because cp fails instantly
sleep 1
cp 'file1' 'file2' > /dev/null 2>&1
stop_spinner $? '🥺'