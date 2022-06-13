#!/bin/bash

# 此脚本目标为通过ansible传递脚本来安装docker版的exporter
# ansible 执行脚本命令为: ansible -i hosts all -u root  -vv -m script -a "./install-node-exporter.sh install_exporter Node_Exporter"


install_exporter(){
curl -L get.docker.io|sh -

case $1 in 
Node_Exporter)
  docker run -d --name node_exporter \
        --restart=always \
        --net="host" \
        --pid="host" \
        --privileged=true \
        -v "/proc:/host/proc:ro" \
        -v "/sys:/host/sys:ro" \
        -v "/:/rootfs:ro" \
        bitnami/node-exporter \
        --path.procfs=/host/proc \
        --path.rootfs=/rootfs \
        --path.sysfs=/host/sys \
        --collector.filesystem.ignored-mount-points='^/(sys|proc|dev|host|etc)($$|/)'
esac

docker ps -a|grep node_exporter

}

uninstall_exporter(){
case $1 in 
Node_Exporter)
  docker rm -f node_exporter
esac
}


$@