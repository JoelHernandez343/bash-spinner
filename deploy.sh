#!/bin/bash

function _clock() {
    
    case $1 in
        start)
            printf "   🕛  ${2}"
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
                echo -en "🟢"
            else
                echo -en "🔴"
            fi
            echo -e "  ${4}"
            ;;
        *)
            echo "invalid argument, try {start/stop}"
            exit 1
            ;;
    esac
}

message=""

function start_clock {
    # $1 : msg to display
    message=`echo ${1}`
    _clock "start" "${1}" &
    # set global spinner pid
    _sp_pid=$!
    disown
}

function stop_clock {
    # $1 : command exit status
    _clock "stop" $1 $_sp_pid "$message"
    unset _sp_pid
}

printf "\n"



start_clock 'Actualizando el sistema y instalando JDK y mysql'
sudo apt -qq update 2>/dev/null > /dev/null
sudo apt -qq -o Dpkg::Use-Pty=0 install openjdk-8-jdk-headless mysql-server unzip -y -qq 2>/dev/null > /dev/null
sleep 3
stop_clock $?


start_clock 'Instalando tomcat'
sleep 3
wget -q https://downloads.apache.org/tomcat/tomcat-8/v8.5.60/bin/apache-tomcat-8.5.60.zip
unzip -qq apache*.zip
rm apache*.zip
cd apache*/
rm webapps -r
mkdir webapps
mkdir webapps/ROOT
wget -qq https://repo1.maven.org/maven2/org/glassfish/jersey/bundles/jaxrs-ri/2.24/jaxrs-ri-2.24.zip
unzip -qq jax*.zip
rm jax*.zip
cp jaxrs-ri/api/*.jar lib
cp jaxrs-ri/ext/*.jar lib
cp jaxrs-ri/lib/*.jar lib
rm jaxrs-ri/ -r
rm lib/javax.servlet-api-3.0.1.jar
cd lib
wget -q https://repo1.maven.org/maven2/com/google/code/gson/gson/2.3.1/gson-2.3.1.jar
wget -q https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-8.0.22.zip
unzip -qq mysql*.zip
cp mysql*/mysql*.jar .
rm mysql*/ -r
rm mysql*.zip
stop_clock $?


cd ../
export CATALINA_HOME=$(pwd)
cd ../
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64

printf "   🕛 🕛 Configuring MySQL: 🕛 🕛\n"
printf "      Please enter 'root' as root's password and 'hugo' as hugo password\n"
sudo mysql_secure_installation
sudo mysql < sudo.sql
printf "      Enter root's password: (root)\n"
mysql -u root -p < root.sql
printf "      Enter hugo's password: (hugo)\n"
mysql -u hugo -p < db.sql
printf "   🟢 Configured MySQL\n"


start_clock 'Iniciando la aplicacion'
unzip -qq Servicio.zip
rm Servicio.zip
cd Servicio
javac -cp $CATALINA_HOME/lib/javax.ws.rs-api-2.0.1.jar:$CATALINA_HOME/lib/gson-2.3.1.jar:. negocio/Servicio.java
rm -f WEB-INF/classes/negocio/*
cp negocio/*.class WEB-INF/classes/negocio/
jar cvf Servicio.war WEB-INF META-INF > /dev/null
rm -f $CATALINA_HOME/webapps/Servicio.war
rm -f -r $CATALINA_HOME/webapps/Servicio
cp Servicio.war $CATALINA_HOME/webapps
cd ../
mv usuario_sin_foto.png $CATALINA_HOME/webapps/ROOT/
mv WSClient.js $CATALINA_HOME/webapps/ROOT/
mv prueba.html $CATALINA_HOME/webapps/ROOT/
sh $CATALINA_HOME/bin/catalina.sh start > /dev/null
stop_clock $?
printf "\n   Tomcat server is running at port 8080. Stop with ${CATALINA_HOME}/bin/catalina.sh stop\n"


