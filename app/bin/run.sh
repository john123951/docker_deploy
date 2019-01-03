SOURCE="$0"
while [ -h "$SOURCE"  ]; do # resolve $SOURCE until the file is no longer a symlink
    DIR="$( cd -P "$( dirname "$SOURCE"  )" && pwd  )"
    SOURCE="$(readlink "$SOURCE")"
    [[ $SOURCE != /*  ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
cd "$( cd -P "$( dirname "$SOURCE"  )" && pwd  )"/..

UNI_HOME=`pwd`

MAIN_CLASS=uni.Application

PID_FILE=$UNI_HOME'/bin/.program.pid'
#PROFILE=`cat $UNI_HOME/profile`
PROFILE=$2

usage(){
    echo "Usage: ${0##*/} {start|stop|restart|check} "
    exit 1
}

[ $# -gt 0 ] || usage

##################################################
# Setup JAVA if unset
##################################################
if [ -z "$JAVA" ]; then
  JAVA=$(which java)
fi

if [ -z "$JAVA" ]; then
  echo "Cannot find a Java JDK. Please set either set JAVA or put java (>=1.5) in your PATH." 2>&2
  exit 1
fi



#CLASSPATH=${UNI_HOME}'/conf'
CLASSPATH=${CLASSPATH}
#-------------------------- class path jar package -----------------------
SEARCH_JAR_PATH=(
        "$UNI_HOME/lib"
        )

for jarpath in ${SEARCH_JAR_PATH[@]}; do
        for file in $jarpath/*.jar; do
                # check file is in classpath
                result=$(echo "$CLASSPATH" | grep "$file")
                if [[ "$result" == "" ]]; then
                        CLASSPATH=$file;
                fi
        done
done

#------------------------- memeory setting --------------------------
#JAVA_OPTS+=(" -Xms1024m -Xmx3g  -XX:MaxDirectMemorySize=6g  ")
#JAVA_OPTS+=(" -Xms3550m -Xmx6G -Xmn2G -XX:MaxDirectMemorySize=8g  ")
#JAVA_OPTS+=(" -Xms1024m -Xmx3G -Xmn2G -XX:MaxDirectMemorySize=8g  ")

#------------------------- print setting --------------------------
#JAVA_OPTS+=(" -XX:+PrintGCDateStamps -XX:+PrintGCTimeStamps -XX:+PrintGCDetails ")
JAVA_OPTS+=(" -XX:+UseCMSCompactAtFullCollection -XX:+UseParNewGC -XX:+CMSParallelRemarkEnabled ")

#------------------------- program value setting --------------------------
#JAVA_OPTS+=(" -Drest.config.file=$PROJECT_HOME/conf/ecloud-config.xml  ")
#JAVA_OPTS+=(" -DSQOOP_CONF_DIR=$PROJECT_HOME/conf ")
#JAVA_OPTS+=(" -Dplatform.config.path=$PROJECT_HOME/conf ")
#JAVA_OPTS+=(" -Dlog4j.configureFile=$LOG_CONF_FILE ")

#------------------------- jvm jmx monitor value setting --------------------------
#JAVA_OPTS+=(" -Dcom.sun.management.jmxremote ")
#JAVA_OPTS+=(" -Dcom.sun.management.jmxremote.authenticate=false ")
#JAVA_OPTS+=(" -Dcom.sun.management.jmxremote.ssl=false ")
#JAVA_OPTS+=(" -Dcom.sun.management.jmxremote.port=$JMX_PORT ")
#JAVA_OPTS+=(" -Djava.library.path=/usr/lib/hadoop/lib/native/Linux-amd64-64 ")

#------------------------- jvm jmx monitor value setting --------------------------
#JAVA_OPTS="$JAVA_OPTS "

#------------------------- profile --------------------------
if [ -n $PROFILE ]; then
  echo "Current profile: $PROFILE"
  JAVA_OPTS="$JAVA_OPTS -Dspring.profiles.active=$PROFILE "
fi

echo $JAVA_OPTS

#-------------------------------------------------------
function start_program(){

	if [ -f $PID_FILE ]; then
      echo "program is running exit."
	  exit 0
    fi
    echo -n "starting program ... "
      #nohup ${JAVA} -Dspring.profiles.active=${PROFILE} ${JAVA_OPTS} -jar $CLASSPATH > /dev/null 2>&1 &
      #${JAVA} -Dspring.profiles.active=${PROFILE} ${JAVA_OPTS} -jar $CLASSPATH 
      ${JAVA} ${JAVA_OPTS} -jar $CLASSPATH 
    if [ $? -eq 0 ]
    then
      if /bin/echo -n $! > "$PID_FILE"
      then
        #sleep 1
        echo STARTED
      else
        echo FAILED TO WRITE PID
        exit 1
      fi
    else
      echo PROGRAM DID NOT START
      exit 1
    fi
}

#-------------------------------------------------------
function stop_program(){
	#--------------------------- kill program start --------------------	
	echo -n "Stopping program ... "
    if [ ! -f "$PID_FILE" ]
    then
      echo "no the program to stop (could not find file $PID_FILE)"
    else
     	kill -9  $(cat "$PID_FILE")
      rm "$PID_FILE"
      echo STOPPED
    fi
}




ACTION=$1
case "$ACTION" in
  start)
	start_program
  ;;
  stop)
	stop_program
  ;; 
  restart)
	stop_program
	start_program
  ;; 
  check)
    echo "Checking arguments to $PROJECT_NAME: "
    echo "JAVA_HOME     		=  $JAVA_HOME"
    echo "UNI_HOME     	=  $UNI_HOME"
    echo "LOG_FILE     		=  $LOG_FILE"
    echo "MAIN_JAR     		=  $MAIN_JAR"
    echo "MAIN_CLASS		=  $MAIN_CLASS"
    echo "JAVA_OPTIONS   		=  ${JAVA_OPTIONS[*]}"
    echo "SEARCH_JAR_PATH	=  ${SEARCH_JAR_PATH[*]}"
    echo "JAVA           		=  $JAVA"
    echo "CLASSES_PATH      	=  $CLASSPATH"
    echo

    if [ -f $PID_FILE ];
    then
      echo "RUNNING PID	=$(cat "$PID_FILE")"
      exit 0
    fi
    exit 1

    ;;
  *)
    usage
    ;;
esac
  
exit 0
