# mysqladmin-tools

## ansible
用于快速构建MySQL集群环境的ansible工具,包含各种集群安装功能:
 - MySQL单机版
 - MySQL双主 + Keepalived
 - 单主多从复制 + MHA
 - 多从级联复制
 - Galera Percona XtraDB Cluster
 - MySQL Group Replication
 - ProxySQL
 - Zabbix + TokuDB + fpmmm
 - Redis + Consul

[查看文档](../../tree/master/ansible)

交流QQ群:141534961

# MySQL DBA 工具 之 ansible

## 介绍
一个用于快速构建MySQL集群环境的ansible工具,包含MySQL双主 + Keepalived,单主多从复制+MHA,多从级联复制,Galera-PXC,MySQL Group Replication,ProxySQL,Zabbix + fpmmm等集群环境一键安装功能.

提供给MySQL DBA及学习爱好者的一个基于ansible的快速环境搭建工具集.



### 配置ansible
```
yum -y install ansible sshpass



# 设置 SSH 公钥认证,
ssh-keygen -t rsa
# 方式一:
ansible all -u root -m shell -a "mkdir /root/.ssh" --ask-pass -c paramiko
ansible all -u root -m copy -a "src=/root/.ssh/id_rsa.pub dest=/tmp/id_rsa.pub" --ask-pass -c paramiko
ansible all -u root -m shell -a "cat /tmp/id_rsa.pub >> /root/.ssh/authorized_keys" --ask-pass -c paramiko

# 方式二:
sshpass -p vagrant ssh-copy-id -o StrictHostKeyChecking=no 192.168.1.101
sshpass -p vagrant ssh-copy-id -o StrictHostKeyChecking=no 192.168.1.102
sshpass -p vagrant ssh-copy-id -o StrictHostKeyChecking=no 192.168.1.103


```

### 配置ansible role path
```
# 将common roles 路径加到 roles_path中
vi +/roles_path/ /etc/ansible/ansible.cfg
grep roles_path /etc/ansible/ansible.cfg
roles_path    = /etc/ansible/roles:/usr/share/ansible/roles:/home/pavia/gitrepo/mysqladmin-tools/ansible/common
filter_plugins = /home/pavia/gitrepo/mysqladmin-tools/ansible/common/mysql/filter_plugins
```

### 安装包文件目录
由于MySQL二进制安装包过大,不适合放在项目中,所需的软件安装包请先自动下载好.


```
所需安装包清单:
# ll /vagrant/downloads
fpmmm-1.0.1.tar.gz
keepalived-1.4.3.tar.gz
mariadb-10.3.9-linux-x86_64.tar.gz
mha4mysql-manager-0.58-0.el7.centos.noarch.rpm
mha4mysql-node-0.58-0.el7.centos.noarch.rpm
mydumper-0.9.5-2.el7.x86_64.rpm
mysql-5.7.38-linux-glibc2.12-x86_64.tar.gz
mysql-8.0.11-linux-glibc2.12-x86_64.tar.gz
Percona-Server-5.7.23-23-Linux.x86_64.ssl101.tar.gz
percona-xtrabackup-24-2.4.12-1.el7.x86_64.rpm
Percona-XtraDB-Cluster-5.7.22-rel22-29.26.1.Linux.x86_64.ssl101.tar.gz
proxysql-1.4.12-1-centos7.x86_64.rpm
proxysql-rc1_2.0.0-1-centos7.x86_64.rpm
zabbix-3.4.14.tar.gz
```

## 使用mysqladmin-tools
本项目采用ansible roles来重用common下公共role,sites下的各种环境是对roles的重用,安装时只需修改相应的hosts及var文件即可.

### 入门使用: mysql-standalone 单机版MySQL安装
使用之前,你应该先了解一下ansible roles:

https://docs.ansible.com/ansible/latest/user_guide/playbooks_reuse_roles.html



[MySQL单机版安装](../../../tree/master/ansible/sites/mysql-standalone)

### 高级使用: 集群环境安装
 - [MySQL Group Replication集群安装](../../../tree/master/ansible/sites/mysql-mgr)
 - [Galera PXC集群安装](../../../tree/master/ansible/sites/mysql-pxc)
 - [MySQL 双主 + keepalived](../../../tree/master/ansible/sites/mysql-mm-keepalived)
 - [MySQL 一主多从 + MHA](../../../tree/master/ansible/sites/mysql-mss-mha)
 - [zabbix + MySQL集群监控](../../../tree/master/ansible/sites/zabbix)
 - [proxysql + MySQL集群代理](../../../tree/master/ansible/sites/proxysql)
 - 更多定制等你来实现.

 交流QQ群:141534961