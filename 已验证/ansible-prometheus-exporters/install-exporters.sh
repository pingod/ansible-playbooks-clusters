#!/bin/bash

# 此脚本目标为通过ansible传递脚本来安装docker版的exporter
# ansible 执行脚本命令为: ansible -i hosts all -u root  -vv -m script -a "./install-exporters.sh install_exporter Node_Exporter"

#DEV
export mysql_user='root' 
export mysql_password='e0LmwJmTOc4lYXAE'
export mysql_host=$(hostname -I|awk '{print $1}')
export redis_host=$(hostname -I|awk '{print $1}')
export redis_password='thundersoft-redis'
export es_host=$(hostname -I|awk '{print $1}')
export mongodb_host=$(hostname -I|awk '{print $1}')


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
  echo '下面将创建exporter容器'
  docker run --name mysql_exporter --restart always -d -p 9104:9104  -e DATA_SOURCE_NAME="mysqlexporter:mysqlexporter@(${mysql_host}:3306)/"  prom/mysqld-exporter:latest
;;

Redis_Exporter)
  sh -c 'docker ps -a|grep redis_exporter' > /dev/null
  if [[ $? == '0' ]];then
    echo "redis_exporter已经运行,下面将强制删除"
    docker rm -f redis_exporter
  fi
    docker run -d --restart always --name redis_exporter \
    -p 9121:9121 oliver006/redis_exporter \
    --redis.addr redis://${redis_host}:6379 \
    --redis.password ${redis_password} 

    sleep 3
    docker ps -a|grep redis_exporter
;;

Es_Exporter)
#https://github.com/prometheus-community/elasticsearch_exporter
  sh -c 'docker ps -a|grep es_exporter' > /dev/null
  if [[ $? == '0' ]];then
    echo "es_exporter已经运行,下面将强制删除"
    docker rm -f es_exporter
  fi
    docker run -d --restart always --name es_exporter \
    --network host \
    -p 9114:9114 bitnami/elasticsearch-exporter \
    --es.timeout=20s \
    --es.uri=http://${es_host}:9200

    sleep 3
    docker ps -a|grep es_exporter
;;

Mongodb_Exporter)
#https://github.com/percona/mongodb_exporter
  sh -c 'docker ps -a|grep mongodb_exporter' > /dev/null
  if [[ $? == '0' ]];then
    echo "mongodb_exporter 已经运行,下面将强制删除"
    docker rm -f mongodb_exporter
  fi
    docker run -d --restart always --name mongodb_exporter \
    -p 9216:9216 -p 17001:17001 \
    percona/mongodb_exporter:0.32 \
    --mongodb.uri=mongodb://admin:e0LmwJmTOc4lYXAE@${mongodb_host}:20000 \
    --compatible-mode \
    --collect-all 

    # 9216为metrics端口 
    # metrics兼容模式,目前大部分grafana目标都是旧版本metrics,建议开启compatible-mode
    sleep 3
    docker ps -a|grep mongodb_exporter
;;

esac

}

uninstall_exporter(){
case $1 in 
Node_Exporter)
  docker rm -f node_exporter
  docker ps -a|grep node_exporter || echo 'uninstalled'
;;
Mysql_Exporter)
  docker rm -f mysql_exporter
  docker ps -a|grep mysql_exporter || echo 'uninstalled'
;;
Redis_Exporter)
  docker rm -f redis_exporter
  docker ps -a|grep redis_exporter || echo 'uninstalled'
;;
Es_Exporter)
  docker rm -f es_exporter
  docker ps -a|grep es_exporter || echo 'uninstalled'
;;
Mongodb_Exporter)
  docker rm -f mongodb_exporter
  docker ps -a|grep mongodb_exporter || echo 'uninstalled'
;;
esac
}


$@