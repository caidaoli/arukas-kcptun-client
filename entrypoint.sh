KcptunKey=${KcptunKey:-password}
if [ -e "/isrun" ];then
   echo "entrypoint already running"
   exit 0
fi
echo 1 >/isrun
rawJson=`curl -s -u $Token:$Secret https://app.arukas.io/api/containers -H "Content-Type: application/vnd.api+json" -H "Accept: application/vnd.api+json" | jq '.data'`
length=`echo $rawJson | jq "length"`
addr="lost"
port="0"
aimAddr="\"$Endpoint\""
aimPort=$Port
for((i=0;i<$length;i++)) ; do
	endP=`echo $rawJson | jq ".[$i].attributes.end_point"`
	if [ "$endP" = "$aimAddr" ] ; then
		portMapping=`echo $rawJson | jq ".[$i].attributes.port_mappings|.[0]"`
		portMappingLength=`echo $portMapping | jq "length"`
		for((j=0;j<$portMappingLength;j++)) ; do
			cPortJson=`echo $portMapping | jq ".[$j]"`
			cPort=`echo $cPortJson | jq ".container_port"`
			if [ "$cPort" = "$aimPort" ] ; then
				port=`echo $cPortJson | jq ".service_port"`
				addr=`echo $cPortJson | jq ".host" | awk -F '"' '{printf $2}'`
				#addr=`host $addr | awk -F 'address ' '{printf $2}'`
			  addr=`nslookup $addr 114.114.114.114 |grep Address | tail -1 | cut -d ":" -f 2`
        break 2
			fi
		done
	fi
done
if [ "$addr" = "lost" -o "$port" = "0" ] ; then
	echo "Query Failed."
  pkill client
	rm -rf /isrun
  exit 1
fi

echo "Query OK!Remote Address is $addr:$port"
if [ -e "/arukas.host" ];then
  old=`cat /arukas.host`
else
  old=''
fi
if [ "$addr:$port" = "$old" ];then
  echo "arukas docker host address not change"
  rm -rf /isrun
  exit
fi
pkill client
echo "$addr:$port" > /arukas.host
client -r $addr:$port -mode fast2 -dscp 46 -mtu 1400 -crypt salsa20 -sndwnd 2048 -rcvwnd 2048 -autoexpire 60 -l :4440 -key $KcptunKey &
rm -rf /isrun
