# 利用arukas的api自动获取运行kcptun server的docker的主机地址和端口。
####arukas的IP和端口是动态的。应用重启或者其他某些原因，会导致IP端口变化。一般每周甚至一天重启一次。Endpoint 是固定的，但是Endpoint不支持 TCP/UDP协议，只支持HTTP。每次都登录进去查看ip和端口很不爽。
####此docker镜像是利用arukas的api获取json信息，并解析对应的ip和端口，如果发生了变化，就重启kcptun的client来保证服务的持续可用性。检查频率是1分钟一次
	使用此镜像需要设置的环境变量
1. 	Token
1. 	Secret
1. 	Endpoint
1. 	Port

#####Token和Secret通过 https://app.arukas.io/settings/api-keys 获取。
####Endpoint 是目标容器的Endpoint ，可以通过此 Endpoint 来标识目标容器。
#####Port 是目标容器的自定义端口，此端口是创建 docker 时自己填的那个，比如22和8388和80什么的

#####kcptun client的端口为4440
