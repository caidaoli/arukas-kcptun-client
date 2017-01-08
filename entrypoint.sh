KcptunKey=${KcptunKey:-password}
if [ -e "/isrun" ];then
   echo "entrypoint already running"
   exit 0
fi
echo 1 >/isrun
raw="curl -s -u $Token:$Secret https://app.arukas.io/api/containers -H 'Content-Type: application/vnd.api+json' -H 'Accept: application/vnd.api+json'"
json=`$raw | jq ".data[]?.attributes | select(.end_point==\"$Endpoint\") | .port_mappings[][] |select(.container_port==$Port)"`
addr=`echo $json | jq .host | tr -d '""' `
port=`echo $json | jq .service_port `

if [ -z "$addr" -o -z "$port"  ] ; then
	echo "Query Failed. Check you Token, Secert, Endpoint and Port!"
  pkill client
	rm -rf /isrun
  exit 1
fi

ip=`curl -s http://119.29.29.29/d?dn=$addr`
addr=${ip:-$addr}
old=''
echo "Query OK!Remote Address is $addr:$port"
if pgrep -x client > /dev/null; then
  echo "kcptun is running"
  if [ -e "/arukas.host" ];then
    old=`cat /arukas.host`
  fi
fi

if [ "$addr:$port" = "$old" ];then
  echo "arukas docker host address not change"
else
  pkill client
  echo "$addr:$port" > /arukas.host
  client -r $addr:$port -mode fast2 -dscp 46 -mtu 1400 -crypt salsa20 $KcpPara -autoexpire 60 -l :4440 -key $KcptunKey &
fi
rm -rf /isrun

