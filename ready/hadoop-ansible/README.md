This project is copied from [here](https://github.com/ZidaneCA/hadoop-ansible) with following major upgrades (20221021)
- Download files to remote server directly
- Install spark via ansible
- Fixes to some identified issues in installation process
- Deploys all components to `HADOOP_HOME=/home/hadoop/current` to ensure ease of updates when later hadoop versions are released

# Hadoop-ansible
- Install Hadoop cluster with ansible
- Now Support CentOS 7.x
- JDK is  Openjdk-1.8
- Hadoop is the version 3.3.2
- Hive is the version 3.1.2
- Spark is the version 3.0.3

## Before Install
1. Use DNS Server or update /etc/hosts for all servers
2. Zookeeper has installed

## Install Hadoop
1. Get URL and version of desired hadoop version
2. Update the `{{ download_path }}` and `{{ hadoop_url }}` in `vars/var_basic.yml` to desired path on remote server and url of hadoop tar.gz
3. Use ansible template to generate the hadoop configration, so If your want to add more properties, just update the `vars/var_basic.yml` 
4. Update `ha.zookeeper.quorum` in `vars/var_basic.yml`


---
Watch This
```
hdfs_site_properties:
  - {
      "name":"dfs.namenode.secondary.http-address",
      "value":"{{ master_hostname }}:{{ dfs_namenode_httpport }}"
  }
  - {
      "name":"dfs.namenode.name.dir",
      "value":"file:{{ hadoop_dfs_name }}"
  }
  - {
      "name":"dfs.namenode.data.dir",
      "value":"file:{{ hadoop_dfs_data }}"
  }
  - {
      "name":"dfs.replication",
      "value":"{{ groups['workers']|length }}"  # this is  the group "workers" you define in hosts/host 
  }
  - {
    "name":"dfs.webhdfs.enabled",
    "value":"true"
  }
```

### Install Master
check the master.yml
```
- hosts: master 
  remote_user: root
  vars_files:
   - vars/user.yml
   - vars/var_basic.yml
   - vars/var_master.yml
  vars:
     add_user: true           # add user "hadoop"
     generate_key: true       # generate the ssh key
     open_firewall: true      # for CentOS 7.x is firewalld
     disable_firewall: false  # disable firewalld 
     install_hadoop: true     # install hadoop,if you just want to update the configuration, set to false
     config_hadoop: true      # Update configuration
  roles:
    - user                    # add user and generate the ssh key
    - fetch_public_key        # get the key and put it in your localhost
    - authorized              # push the ssh key to the remote server 
    - java                    # install jdk
    - hadoop                  # install hadoop

```
run shell like

```
ansible-playbook -i hosts/host master.yml
```

### Install Workers

```
# Add Master Public Key   # get master ssh public key 
- hosts: master 
  remote_user: jon_doe
  become: true
  vars_files:
   - vars/user.yml
   - vars/var_basic.yml
   - vars/var_workers.yml
  roles:
    - fetch_public_key

- hosts: workers 
  remote_user: root
  vars_files:
   - vars/user.yml
   - vars/var_basic.yml
   - vars/var_workers.yml
  vars:
    add_user: true
    generate_key: false # workers just use master ssh public key
    open_firewall: false
    disable_firewall: true  # disable firewall on workers
    install_hadoop: true
    config_hadoop: true
  roles:
    - user
    - authorized
    - java
    - hadoop
```
run shell like:
```
master_ip:  your hadoop master ip
master_hostname: your hadoop master hostname

above two variables must be same like your real hadoop master

ansible-playbook -i hosts/host workers.yml -e "master_ip=192.168.122.79 master_hostname=hadoop-master-hostname"

```

### Install hive
1. **Create database first and give right authority**
2. check vars/var_hive.yml and update download url of hive if necessary

```
---

# hive basic vars
hive_url: "https://downloads.apache.org/hive/hive-{{ hive_version }}/apache-hive-{{ hive_version }}-bin.tar.gz"
download_path: "/home/user/Downloads"
hive_version: "3.1.2"
hive_path: "/home/hadoop/current"
hive_config_path: "/home/hadoop/current/hive-{{ hive_version }}/conf"
hive_tmp: "/home/hadoop/hive/tmp"

hive_create_path:
  - "{{ hive_tmp }}"

hive_warehouse: "/user/hive/warehouse"
hive_scratchdir: "/user/hive/tmp"
hive_querylog_location: "/user/hive/log"

hive_hdfs_path: 
  - "{{ hive_warehouse }}"
  - "{{ hive_scratchdir }}"
  - "{{ hive_querylog_location }}"

hive_logging_operation_log_location: "{{ hive_tmp }}/{{ user }}/operation_logs"

# database
db_type: "postgres"
hive_connection_driver_name: "org.postgresql.Driver"
hive_connection_host: "192.168.122.201"
hive_connection_port: "5432"
hive_connection_dbname: "hive"
hive_connection_user_name: "hive"
hive_connection_password: "db_password"
hive_connection_url: "jdbc:postgresql://{{ hive_connection_host }}:{{ hive_connection_port }}/{{hive_connection_dbname}}?ssl=false"
# hive configration 
hive_site_properties:
  - {
      "name":"hive.metastore.warehouse.dir",
      "value":"hdfs://{{ master_hostname }}:{{ hdfs_port }}{{ hive_warehouse }}"
  }
  - {
      "name":"hive.exec.scratchdir",
      "value":"{{ hive_scratchdir }}"
  }
  - {
      "name":"hive.querylog.location",
      "value":"{{ hive_querylog_location }}/hadoop"
  }
  - {
      "name":"javax.jdo.option.ConnectionURL",
      "value":"{{ hive_connection_url }}"
  }
  - {
    "name":"javax.jdo.option.ConnectionDriverName",
    "value":"{{ hive_connection_driver_name }}"
  }
  - {
    "name":"javax.jdo.option.ConnectionUserName",
    "value":"{{ hive_connection_user_name }}"
  }
  - {
    "name":"javax.jdo.option.ConnectionPassword",
    "value":"{{ hive_connection_password }}"
  }
  - {
    "name":"hive.server2.logging.operation.log.location",
    "value":"{{ hive_logging_operation_log_location }}"
  }

hive_server_port: 10000
hive_hwi_port: 9999
hive_metastore_port: 9083

firewall_ports:
  - "{{ hive_server_port }}"
  - "{{ hive_hwi_port }}"
  - "{{ hive_metastore_port }}"
```
3. check hive.yml

```
- hosts: hive                   # in hosts/host
  remote_user: jon_doe
  become: true
  vars_files:
   - vars/user.yml
   - vars/var_basic.yml
   - vars/var_master.yml
   - vars/var_hive.yml            # var_hive.yml
  vars:
     open_firewall: true           
     install_hive: true           
     config_hive: true
     init_hive: true               # init hive database after install and config
  roles:
    - hive
```
4. run it

```
ansible-playbook -i hosts/host hive.yml
```


### Install spark
1. **Check vars/var_spark.yml**
2. Update the download url of spark if changed

```
---

# spark basic vars
spark_url: "https://dlcdn.apache.org/spark/spark-{{ spark_version }}/spark-{{ spark_version }}-bin-hadoop{{ hadoop_spa_version }}.tgz"
download_path: "/home/user/Downloads"
spark_version: "3.0.3"
hadoop_spa_version: "3.2"
spark_path: "/home/hadoop/current"
spark_config_path: "/home/hadoop/current/spark-{{spark_version}}/conf"
spark_log: "/home/hadoop/current/spark-{{spark_version}}/logs"

spark_create_path:
  - "{{ spark_log }}"

spark_eventLog_dir: "/user/spark/spark-logs"
spark_history_fs_logDirectory: "/user/spark/spark-logs"

spark_hdfs_path: 
  - "{{ spark_eventLog_dir }}"
  - "{{ spark_history_fs_logDirectory }}"

#spark default conf
spark_master: "yarn"
spark_driver_memory: "512m"
spark_yarn_am_memory: "512m"
spark_executor_memory: "512m"

# spark history server conf
spark_eventLog_enabled: "true"
spark_history_provider: "org.apache.spark.deploy.history.FsHistoryProvider"
spark_history_fs_update_interval: "10s"
spark_history_ui_port: 18080

# spark configration 
spark_default_conf:
  - {
      "name":"spark.eventLog.dir",
      "value":"hdfs://{{ master_ip }}:{{ hdfs_port }}{{ spark_eventLog_dir }}"
  }
  - {
      "name":"spark.history.fs.logDirectory",
      "value":"hdfs://{{ master_ip }}:{{ hdfs_port }}{{ spark_eventLog_dir }}"
  }
  - {
      "name":"spark.master",
      "value":"{{ spark_master }}"
  }
  - {
      "name":"spark.driver.memory",
      "value":"{{ spark_driver_memory }}"
  }
  - {
      "name":"spark.yarn.am.memory",
      "value":"{{ spark_yarn_am_memory }}"
  }
  - {
    "name":"spark.executor.memory",
    "value":"{{ spark_executor_memory }}"
  }
  - {
    "name":"spark.eventLog.enabled ",
    "value":"{{ spark_eventLog_enabled }}"
  }
  - {
    "name":"spark.history.provider",
    "value":"{{ spark_history_provider }}"
  }
  - {
    "name":"spark.history.fs.update.interval",
    "value":"{{ spark_history_fs_update_interval }}"
  }
  - {
    "name":"spark.history.ui.port ",
    "value":"{{ spark_history_ui_port }}"
  }

firewall_ports:
  - "{{ spark_history_ui_port }}"
```
3. check spark.yml

```
- hosts: spark   # in hosts/host
  remote_user: jon_doe
  become: true
  vars_files:
   - vars/user.yml
   - vars/var_basic.yml
   - vars/var_master.yml
   - vars/var_spark.yml
  vars:
     open_firewall: true  # open ports used by spark on firewall (redhat)
     install_spark: true
     config_spark: true
     init_spark: true 
  roles:
    - spark
```
4. run it

```
ansible-playbook -i hosts/host spark.yml

```

## Some possible issues identifed and fixes
1. A note [here](https://www.projectpro.io/hadoop-tutorial/big-data-hadoop-tutorial) says:
   If you encounter any “Incompatible NamespaceID’s” exception then to trouble shoot such error you have to do the following:
   - Stop all the services
   - Delete /tmp/hadoop/dfs/data -> hadoop tmp
   - Start all the services again.

2. SLF4J: Class path contains multiple SLF4J bindings issue as found [here](https://issues.apache.org/jira/browse/HIVE-22915)  and potential fix is implemented in the hive_env.sh file

3. Uncomment `#wget -P $HIVE_HOME/lib/https://jdbc.postgresql.org/download/postgresql-42.2.24.jar in hive_env.sh` file if you are using a postgres version > 13
   this uses a higher java library which supports this version. Fix mentioned [here](https://stackoverflow.com/questions/64210167/unable-to-connect-to-postgres-db-due-to-the-authentication-type-10-is-not-suppor).


## NOTES
1. All PATH variables are kept in `/etc/environment` and sourced to ensure they are usable via ansible user.
2. 
  ```
  args:
     executable: /bin/bash
  ```
   is added to ensure ansible shell commands run. May produce errors otherwise

3. Java Needs to be preinstalled for non-redhat systems
4. If everything runs normally, you can use following commands to start hadoop
   - `hdfs namenode -format  #format hadoop namenode`
   - `start-dfs.sh`
   - `start-yarn.sh`
   - `mapred --daemon start historyserver`

  To stop, use
   - `stop-dfs.sh`
   - `stop-yarn.sh`
   - `mapred --daemon stop historyserver`

5. Remote user isn't root so there is need for the `become: true` and also some configs in hosts/host file


### License

GNU General Public License v3.0