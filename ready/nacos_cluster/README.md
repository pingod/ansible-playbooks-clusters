## ansible安装nacos集群
自动化可扩展ansible 安装nacos
### 准备
1. 下载nacos安装包到ansible执行机器的`/tmp/`下,下载地址为:https://github.com/alibaba/nacos/releases/download/2.1.1/nacos-server-2.1.1.tar.gz
2. 修改ansible的hosts文件，nacos分组下面写入主机ip
3. 修改 nacos/vars/nacos.yml 的变量
4. 要部署的机器需要能够访问互联网,以供安装些依赖工具
5. nacos集群需要使用外置mysql，在部署前请安装好mysql(注意先创建好对应的库)

### 安装
`ansible-playbook -i hosts ./nacos.yml -vv`

### 卸载
`ansible-playbook -i hosts ./roles/nacos/tasks/uninstall_nacos.yml -vv`
