#!/bin/bash

# 此脚本目标为通过ansible传递脚本来安装docker版的exporter
# ansible 执行脚本命令为: ansible -i hosts all -u root  -vv -m script -a "./install-exporters.sh install_exporter Node_Exporter"

#DEV
export mysql_user='root' 
export mysql_password='e0LmwJmTOc4lYXAE'
export mysql_host='10.2.102.133'


install_exporter(){

which docker > /dev/null
if [[ $? == '0' ]];then
  echo "docker-ce已经安装"
else
  curl -L get.docker.io|sh -
fi

case $1 in 
Node_Exporter)
  sh -c 'docker ps -a|grep node_exporter' > /dev/null
  if [[ $? == '0' ]];then
    echo "node_exporter已经运行,下面将强制删除"
    docker rm -f node_exporter
  fi
    docker run -d --name node_exporter \
        --restart=always \
        --net="host" \
        --pid="host" \
        --privileged=true \
        -v "/proc:/host/proc:ro" \
        -v "/sys:/host/sys:ro" \
        -v "/:/rootfs:ro" \
        -v "/run/dbus/system_bus_socket:/var/run/dbus/system_bus_socket:ro" \
        bitnami/node-exporter \
        --path.procfs=/host/proc \
        --path.rootfs=/rootfs \
        --path.sysfs=/host/sys \
        --collector.filesystem.ignored-mount-points='^/(sys|proc|dev|host|etc)($$|/)' \
        --collector.systemd \
        --collector.systemd.unit-whitelist="(docker|nginx|sshd|mysqld).service"
    sleep 3
    docker ps -a|grep node_exporter
;;

Mysql_Exporter)
  sh -c 'docker ps -a|grep mysql_exporter' > /dev/null
  if [[ $? == '0' ]];then
    echo "node_exporter已经运行,下面将强制删除"
    docker rm -f mysql_exporter
  fi

  mysql -u ${mysql_user} -p${mysql_password}  -h 127.0.0.1 -e 'select User,Host from mysql.user \G;' |grep mysqlexporter > /dev/null
  if [[ $? == '0' ]];then
    echo "mysql已经有mysqlexporter用户,将跳过创建用户"
  else
    echo 'mysql中不存在mysqlexporter这个用户,下面将创建该用户并授权'
    cat > create-mysqluser.sql >>EOF
CREATE USER 'mysqlexporter'@"%"  IDENTIFIED BY 'mysqlexporter';
GRANT PROCESS, REPLICATION CLIENT, SELECT ON *.* TO 'mysqlexporter'@'%'  IDENTIFIED BY 'mysqlexporter' WITH MAX_USER_CONNECTIONS 30; 
GRANT select on performance_schema.* to "mysqlexporter"@"%" IDENTIFIED BY 'mysqlexporter';
flush privileges;  
EOF
    mysql -u ${mysql_user} -p${mysql_password}  -h 127.0.0.1  < create-mysqluser.sql
    rm -f create-mysqluser.sql
  fi

  docker run --name mysql_exporter --restart always -d -p 9104:9104  -e DATA_SOURCE_NAME="mysqlexporter:mysqlexporter@(10.2.102.133:3306)/mysql"  prom/mysqld-exporter:latest
;;
esac

}

uninstall_exporter(){
case $1 in 
Node_Exporter)
  docker rm -f node_exporter
  docker ps -a|grep node_exporter
esac
}


$@