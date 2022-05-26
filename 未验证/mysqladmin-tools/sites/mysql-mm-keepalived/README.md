# MySQL 双主 + keepalived 环境安装

## 安装包文件目录
由于MySQL二进制安装包过大,不适合放在项目中,所需的软件安装包请先自动下载好,并上传到所有节点


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
