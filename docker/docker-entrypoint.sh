#!/bin/bash
# Execute JMeter command
set -e
freeMem=`awk '/MemFree/ { print int($2/1024) }' /proc/meminfo`
s=$(($freeMem/10*8))
x=$(($freeMem/10*8))
n=$(($freeMem/10*2))
export JVM_ARGS="-Xmn${n}m -Xms${s}m -Xmx${x}m"

echo "START Running Jmeter Server on `date`"
echo "JVM_ARGS=${JVM_ARGS}"

sed "s/#server.rmi.ssl.disable=false/server.rmi.ssl.disable=$SSL_DISABLED/g" ./bin/jmeter.properties > ./bin/jmeter_temp.properties
mv ./bin/jmeter_temp.properties ./bin/jmeter.properties

if [ "$1" = 'jmeter-server' ]; then
    JMETER_LOG="jmeter-server.log" && touch $JMETER_LOG && tail -f $JMETER_LOG &
fi

exec "$@"