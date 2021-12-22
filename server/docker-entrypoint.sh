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

JMETER_LOG="jmeter-server.log" && touch $JMETER_LOG && tail -f $JMETER_LOG &

exec jmeter-server \
  -Dserver.rmi.localport=60001 \
  -Dserver_port=1099 \
  -Jserver.rmi.ssl.disable=$SSL_DISABLED