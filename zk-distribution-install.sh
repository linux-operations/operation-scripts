#!/bin/bash
read -p "Please Enter Your Servers ip_list(separate by \",\" with no whitespace) :" IP_LIST
read -p "Please Enter The port:" PORT ;

echo You have entered $IP_LIST, $PORT;

# ZK_NODES_LIST=(1 2 3)
USR_HOME_DIR=~
ZK_ROOT_DIR=zookeeper
#ZK_node01_data
ZK_NODE_DATA_DIR_PREFIX=zk.node
ZK_NODE_DATA_DIR_SUFFIX=data
ZK_OP_SCRIPTS_DIR=scripts
ZK_FULL_PATH=${USR_HOME_DIR}/${ZK_ROOT_DIR}

if [[ ! -d "${ZK_FULL_PATH}" ]]; then
	mkdir -pv ${ZK_FULL_PATH}
fi
# explode zookeeper package
tar zxvf zookeeper*tar.gz -C ${ZK_FULL_PATH}/
PKG_EXP_DIR_NAME=$(ls -l ${USR_HOME_DIR} | grep "zookeeper" | grep "tar.gz$" | awk -F " " '{print $9}' |awk -F ".tar" '{print $1}')
CURRENT_HOST_IP=$(ifconfig eth0 | egrep -o "inet addr:[^ ]*" | grep -o "[0-9.]*")
CURRENT_LOGIN_USR=$(whoami)

function InstallZKNode()
{
	ZK_VERSION=$1
	# ZK_NODE_INDEX=$2
	# ZK_NODE_SIZE=$3
	ZK_HOME=zookeeper-${ZK_VERSION}
	
	ZK_SUBPATH_DATA=${ZK_FULL_PATH}/${ZK_NODE_DATA_DIR_PREFIX}.${ZK_NODE_DATA_DIR_SUFFIX}
	ZK_SUBPATH_INSTALL=${ZK_FULL_PATH}/${ZK_HOME}/
	ZK_SUBPATH_SCRITPS=${ZK_FULL_PATH}/${ZK_OP_SCRIPTS_DIR}
	
	if [[ ! -d "${ZK_SUBPATH_DATA}" ]]; then
		mkdir -pv ${ZK_SUBPATH_DATA}
	fi
	
	if [[ ! -d "${ZK_SUBPATH_INSTALL}" ]]; then
		mkdir -pv ${ZK_SUBPATH_INSTALL}
	fi
	
	if [[ ! -d "${ZK_SUBPATH_SCRITPS}" ]]; then
		mkdir -pv ${ZK_SUBPATH_SCRITPS}
	fi
	# do other things
	if [[ ! ${PKG_EXP_DIR_NAME} == ${ZK_HOME} ]]; then
		mv ${ZK_FULL_PATH}/${PKG_EXP_DIR_NAME}/ ${ZK_SUBPATH_INSTALL}
	fi
	
	FUNC_MAKESERVERLIST_OUT=`MakeServerList $IP_LIST`
	echo $FUNC_MAKESERVERLIST_OUT
	
	# for (( j = 0; j < ${ZK_NODE_SIZE} ; j ++ ))
	# do
	CreateNodeConfiguration $ZK_SUBPATH_DATA $ZK_SUBPATH_SCRITPS $FUNC_MAKESERVERLIST_OUT $PORT $ZK_SUBPATH_INSTALL
	# done
}


function CreateNodeConfiguration()
{
	ZK_NODE_DATA_PATH=$1
	ZK_NODE_SCRIPTS_PATH=$2	#/home/martin/zookeeper/scripts
	ZK_NODES_SERVERS_CONFIG=$3 # server.1=10.1.15.10:2888:3888\nserver.2=10.1.15.11:2888:3888\nserver.3=10.1.15.12:2888:3888
	ZK_NODE_PORT=$4
	ZK_INSTALL_PATH=$5	#/home/martin/zookeeper/zookeeper-3.4.5/
	ZK_NODE_TMP_MYID=0
	
	ZK_NODES_IPS=$IP_LIST
	oldIFS=$IFS
	IFS=,
	i=0
	for IP in $ZK_NODES_IPS;
	do
		let i++
		
		echo -e "tickTime=2000\ninitLimit=10\nsyncLimit=5\ndataDir="${ZK_NODE_DATA_PATH}"\nclientPort="${ZK_NODE_PORT}"\n"${ZK_NODES_SERVERS_CONFIG} > ${ZK_INSTALL_PATH}conf/zk.node.cfg
		echo -e ${ZK_INSTALL_PATH}"bin/zkServer.sh start zk.node.cfg" > ${ZK_NODE_SCRIPTS_PATH}/zk.node.start.sh
		echo -e ${ZK_INSTALL_PATH}"bin/zkServer.sh status zk.node.cfg" > ${ZK_NODE_SCRIPTS_PATH}/zk.node.status.sh
		echo -e ${ZK_INSTALL_PATH}"bin/zkServer.sh stop zk.node.cfg" > ${ZK_NODE_SCRIPTS_PATH}/zk.node.stop.sh
		# ./zookeeper/zookeeper-3.4.5/bin/zkCli.sh -server 192.168.153.132:2181
		echo -e "read -p \"Server's Ip:\" SERVER_IP\nread -p \"Server's Port:\" SERVER_PORT\n"${ZK_INSTALL_PATH}"bin/zkCli.sh -server \$SERVER_IP:\$SERVER_PORT" > ${ZK_NODE_SCRIPTS_PATH}/zk.server.connect.sh
		chmod +x ${ZK_NODE_SCRIPTS_PATH}/*
		if [[ ! ${CURRENT_HOST_IP} == ${IP} ]]; then
			echo $i > ${ZK_NODE_DATA_PATH}/myid
			DeployZKNode $IP
		else
			ZK_NODE_TMP_MYID=$i
		fi
	done
	echo $ZK_NODE_TMP_MYID > ${ZK_NODE_DATA_PATH}/myid
	IFS=$oldIFS
}

function DeployZKNode()
{
	DSTN_HOST_IP=$1
	
	# scp -r /home/martin/zookeeper 192.168.153.132:~
	scp -r $ZK_FULL_PATH $CURRENT_LOGIN_USR@$DSTN_HOST_IP:$USR_HOME_DIR
}

function MakeServerList()
{
	SERVER_LIST_STR=""
	#ZK_NODES_IPS=10.1.15.10,10.1.15.11,10.1.15.12,10.1.15.13
	ZK_NODES_IPS=$1
	oldIFS=$IFS
	IFS=,
	i=0
	for IP in $ZK_NODES_IPS;
	do
			let i++
			SERVER_LIST_STR=$SERVER_LIST_STR"server."$i"="$IP":2888:3888\n"         #eg. server.1=10.1.15.10:2888:3888\nserver.2=10.1.15.11:2888:3888\nserver.3=10.1.15.12:2888:3888
	done
	IFS=$oldIFS
	# echo -e $SERVER_LIST_STR
	echo $SERVER_LIST_STR
}

# length=${#ZK_NODES_LIST[*]}
# for node_index in ${ZK_NODES_LIST[@]}
# do
# 	InstallZKNode "3.4.5" ${node_index} $length
InstallZKNode "3.4.5"
# done
