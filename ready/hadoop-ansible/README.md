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
1. Zookeeper has installed(important!!!)
2. use hostnamectl set host name(important!!!):
    hostnamectl set-hostname hdfs01.hdfscluster
    hostnamectl set-hostname hdfs02.hdfscluster
    hostnamectl set-hostname hdfs03.hdfscluster
3. Use DNS Server or update hostname to /etc/hosts(important!!!):
    192.168.88.91 hdfs01 hdfs01.hdfscluster
    192.168.88.92 hdfs02 hdfs02.hdfscluster
    192.168.88.93 hdfs03 hdfs03.hdfscluster

## Install Hadoop
1. Get URL and version of desired hadoop version
2. Update the `{{ download_path }}` and `{{ hadoop_url }}` in `vars/var_basic.yml` to desired path on remote server and url of hadoop tar.gz
3. Use ansible template to generate the hadoop configration, so If your want to add more properties, just update the `vars/var_basic.yml` 
4. Update `ha.zookeeper.quorum` in `vars/var_basic.yml`


### Install Master

run shell like

```
ansible-playbook -i hosts/host master.yml
```

### Install Workers

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
3. check hive.yml
4. run it

```
ansible-playbook -i hosts/host hive.yml
```


### Install spark
1. **Check vars/var_spark.yml**
2. Update the download url of spark if changed
3. check spark.yml
4. run it

```
ansible-playbook -i hosts/host spark.yml

```

## Some possible issues identifed and fixes
1. A note [here](https://www.projectpro.io/hadoop-tutorial/big-data-hadoop-tutorial) says:
   If you encounter any “Incompatible NamespaceID’s” exception then to trouble shoot such error you have to do the following:
   - Stop all the services
   - Delete /home/hadoop/dfs/data/ -> hadoop tmp
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
