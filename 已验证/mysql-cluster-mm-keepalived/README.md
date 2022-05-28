## 介绍
一个用于快速构建MySQL集群环境的ansible工具,包含MySQL双主 + Keepalived集群环境一键安装功能.
本项目采用ansible roles来重用common下公共role,sites下的各种环境是对roles的重用,安装时只需修改相应的hosts及var文件即可.


### 配置ansible
```
pip3 install ansible 
apt install -y sshpass
```

### 配置ssh免登录(远端为root)
ansible -i ./hosts copysshkey-host-group -m authorized_key -a "user=root  key='{{ lookup('file','~/.ssh/id_rsa.pub') }}'" -u modelzoo -k -b -K


### 配置ansible role path
```
# 将common roles 路径加到/etc/ansible/ansible.cfg文件的roles_path中
  roles_path    = /etc/ansible/roles:/usr/share/ansible/roles:/home/pavia/gitrepo/mysqladmin-tools/ansible/common
  filter_plugins = /home/pavia/gitrepo/mysqladmin-tools/ansible/common/mysql/filter_plugins
```

### 安装包文件目录
由于MySQL二进制安装包过大,不适合放在项目中,所需的软件安装包请先自动下载好.


```
所需安装包清单:
keepalived-1.4.3.tar.gz
mysql-5.7.38-linux-glibc2.12-x86_64.tar.gz
```


# MySQL 双主 + keepalived 环境安装

## 用法:

    # 生产环境
	ansible-playbook -i inventories/production/hosts site.yml

	# 测试环境
	ansible-playbook -i inventories/staging/hosts site.yml

## 主配置文件:

    var/main.yml

## 启动mysql:

	ansible all -i hosts -m shell -a "/data/mysql/start_mysql.sh 3306"

## 检查Slave Status:

	ansible all -i hosts -m shell -a "mysql -S /tmp/mysql3306.sock -paaaaaa -e 'show slave status\G'"

## 测试方法

    # node1
    systemctl start keepalived
    tailf /var/log/messages

    # node2
    systemctl start keepalived
    tailf /var/log/messages

    # vip
    ssh 192.168.1.200
    mysql -S /tmp/mysql3306.sock -p
