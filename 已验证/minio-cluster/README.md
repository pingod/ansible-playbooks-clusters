Ansible Role: Minio Server Installation and Configuration
=========
The following playbook install and configure minio server and client, enabling TLS and generating self-signed SSL certificates.
It also create some buckets and users with proper ACLs

# 功能说明
1. 一键创建minio集群(注意集群需要至少4块硬盘)
2. 创建支持https的console(自签证书)
3. 创建Console的Demo用户和权限
4. minio服务开机自启动

# 使用说明
## 前置条件
1. 部署机安装好ansible
2. 部署机到远程机器的SSH已经配置ssh互信秘钥登录(root用户)
3. 部署机具备minio的离线二进制文件（server端：minio ,client端：mc，证书生成工具：certgen），若部署机没有，请确保远端具备互联网访问，以供自动下载。
4. 将需要部署minio的机器IP填写到[minio]分组下面。
5. 按照自身需求修改`defaults\main.yaml`文件中的变量值


## 安装
ansible-playbook -i ./hosts  install-minio.yml --u root  -vv

## 卸载
ansible-playbook -i ./hosts  uninstall-minio.yml --u root  -vv
