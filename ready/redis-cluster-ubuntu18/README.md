# Ansible 部署 Redis 集群

> 下面所有操作在 Ubuntu 18.04 中进行。

此 Ansible 的功能为构建 Redis 集群，会在每个目标主机中部署两个 Redis 实例，下面演示构建一个 3 节点 6 实例的 Redis 集群。

---

1、准备一台管理机执行,安装 Ansible

2、 取消 Ansible 检查 Key ：

```bash
$ vim /etc/ansible/ansible.cfg
# 取消此行注释
host_key_checking = False
```

3、配置主机清单：

```bash
$ vim hosts
```

> 上述配置会在 `10.1.30.12` 、`10.1.30.13` 和 `10.1.30.41` 中各安装两个 Redis 实例，Master 实例占用 `master_port` 指定的端口，Slave 实例占用 `slave_port` 指定的端口。

5、执行 Playbook，执行完成后会输出一个构建集群的命令，如下：

```bash
$ ansible-playbook -i hosts.yml run.yml
...
TASK [start_service : 打印构建 Redis 集群的命令] ****************************************************************************************************************************************************************************************
ok: [10.1.30.12] => {
    "msg": "redis-cli -a 123 --cluster create 10.1.30.12:6379 10.1.30.13:6379 10.1.30.41:6379 10.1.30.12:6380 10.1.30.13:6380 10.1.30.41:6380 --cluster-replicas 1"
}

PLAY RECAP *********************************************************************************************************************************************************************************************************************
10.1.30.12                 : ok=19   changed=8    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
10.1.30.13                 : ok=18   changed=8    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
10.1.30.41                 : ok=18   changed=8    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
```

6、执行该命令构建集群关系：

```bash
$ redis-cli -a de2fae62fagag2fmjkgm --cluster create 10.1.30.12:6379 10.1.30.13:6379 10.1.30.41:6379 10.1.30.12:6380 10.1.30.13:6380 10.1.30.41:6380 --cluster-replicas 1
Warning: Using a password with '-a' or '-u' option on the command line interface may not be safe.
>>> Performing hash slots allocation on 6 nodes...
Master[0] -> Slots 0 - 5460
Master[1] -> Slots 5461 - 10922
Master[2] -> Slots 10923 - 16383
Adding replica 10.1.30.13:6380 to 10.1.30.12:6379
Adding replica 10.1.30.41:6380 to 10.1.30.13:6379
Adding replica 10.1.30.12:6380 to 10.1.30.41:6379
M: 20adb8e24d280e0c59bd0af65d8ef9a4da057e7c 10.1.30.12:6379
   slots:[0-5460] (5461 slots) master
M: 2b8f8221e24201490d52d175950000eb915669d7 10.1.30.13:6379
   slots:[5461-10922] (5462 slots) master
M: ac298b24c8e7e5b56255e14cfe705b0116113020 10.1.30.41:6379
   slots:[10923-16383] (5461 slots) master
S: 787dc3f6521724b62b57b7c0aac209c3be2f7d2a 10.1.30.12:6380
   replicates ac298b24c8e7e5b56255e14cfe705b0116113020
S: 2874f56d538cfaf26179093a89755dfb28122e54 10.1.30.13:6380
   replicates 20adb8e24d280e0c59bd0af65d8ef9a4da057e7c
S: afcd5fb139c14c0a7429ba5e351551fbe22eb1ac 10.1.30.41:6380
   replicates 2b8f8221e24201490d52d175950000eb915669d7
Can I set the above configuration? (type 'yes' to accept): yes
>>> Nodes configuration updated
>>> Assign a different config epoch to each node
>>> Sending CLUSTER MEET messages to join the cluster
Waiting for the cluster to join

>>> Performing Cluster Check (using node 10.1.30.12:6379)
M: 20adb8e24d280e0c59bd0af65d8ef9a4da057e7c 10.1.30.12:6379
   slots:[0-5460] (5461 slots) master
   1 additional replica(s)
M: ac298b24c8e7e5b56255e14cfe705b0116113020 10.1.30.41:6379
   slots:[10923-16383] (5461 slots) master
   1 additional replica(s)
S: 787dc3f6521724b62b57b7c0aac209c3be2f7d2a 10.1.30.12:6380
   slots: (0 slots) slave
   replicates ac298b24c8e7e5b56255e14cfe705b0116113020
M: 2b8f8221e24201490d52d175950000eb915669d7 10.1.30.13:6379
   slots:[5461-10922] (5462 slots) master
   1 additional replica(s)
S: 2874f56d538cfaf26179093a89755dfb28122e54 10.1.30.13:6380
   slots: (0 slots) slave
   replicates 20adb8e24d280e0c59bd0af65d8ef9a4da057e7c
S: afcd5fb139c14c0a7429ba5e351551fbe22eb1ac 10.1.30.41:6380
   slots: (0 slots) slave
   replicates 2b8f8221e24201490d52d175950000eb915669d7
[OK] All nodes agree about slots configuration.
>>> Check for open slots...
>>> Check slots coverage...
[OK] All 16384 slots covered.
```

7、检查集群节点关系：

```bash
$ redis-cli --cluster info 10.1.30.12:6379 -a 123
Warning: Using a password with '-a' or '-u' option on the command line interface may not be safe.
10.1.30.12:6379 (20adb8e2...) -> 0 keys | 5461 slots | 1 slaves.
10.1.30.41:6379 (ac298b24...) -> 0 keys | 5461 slots | 1 slaves.
10.1.30.13:6379 (2b8f8221...) -> 0 keys | 5462 slots | 1 slaves.
```

From: https://github.com/zze326/ansible-deploy-redis-cluster.git
