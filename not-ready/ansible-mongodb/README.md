# Ansible Role - mongodb

Configure the components of a MongoDB Cluster

Available on Ansible Galaxy: [isaackehle.mongodb](https://galaxy.ansible.com/isaackehle/mongodb)

## Variables

Required definitions are as follows:

```yaml
cfg_server:
  name: "my-cfg" # (Required)
  group: "my-cfg-servers" # (Required) Always pass in the group id used for the config servers

replica_set:
  name: "my-cfg" # name of the replica set for the config server (prefix of fqdn)
  group: "my-cfg-servers" # group name for all servers in the replica set
```

Host Definitions typically contain the following:

### Replica Set Only

```yaml
cluster_role: "replicaSet"
```

### Router Server

```yaml
cluster_role: "router"
```

### Config Server

```yaml
cluster_role: "config"
replica_set:
  name: "my-cfg" # name of the replica set for the config server (prefix of fqdn)
  group: "my-cfg-servers" # group name for all servers in the replica set
```

### Shard Server

```yaml
cluster_role: "shard"
replica_set:
  name: "db-data" # name of the replica set for the shard server (prefix of fqdn)
  group: "db-data-servers" # group name for all servers in the replica set
```

## Tags/Flags

I use a system of flags and tags that allow the calling playbook to specify which roles are run.
As an example:

```bash
ansible-playbook playbooks/mongodb.yml -e "{'flags': ['install']}"
ansible-playbook playbooks/mongodb.yml -e "{'flags': ['save_config']}"
ansible-playbook playbooks/mongodb.yml -e "{'flags': ['reset_storage']}"
ansible-playbook playbooks/mongodb.yml -e "{'flags': ['init_replica_set']}"
ansible-playbook playbooks/mongodb.yml -e "{'flags': ['add_shard_to_cluster']}"
ansible-playbook playbooks/mongodb.yml -e "{'flags': ['create_database']}"
```

## Flags and Variables

| Flag                 | Purpose                                                                          |
| -------------------- | -------------------------------------------------------------------------------- |
| install              | Install mongo packages                                                           |
| save_config          | Basic initialization. Stop Services, push service/config files, restart services |
| reset_storage        | Clear directories and logs                                                       |
| init_replica_set     | Initialize the replica set configuration                                         |
| add_shard_to_cluster | Add a replica set of a shard server to the cluster of shard servers              |
| create_database      | Do an initial database creation, with username and password                      |

```yaml
vars:
  flags: ["install"]
  new_shard:
    name: # Name of the replica set to add to the config server
    server: # One of the members of the new replicate set to add
```

## Examples

```yaml
- hosts: all
  vars:
    auth_db: ""
    adminUser: ""
    adminPass: ""
    tgt_db: ""
    userName: ""
    userPass: ""
    roles: ["readWrite", "userAdmin"]

    # For when initializing the replica set
    adminUser: ''
    adminPass: ''

  roles:
    - { role: isaackehle.mongodb, flags: ['install'] }
    - { role: isaackehle.mongodb, flags: ['save_config'] }
    - { role: isaackehle.mongodb, flags: ['reset_storage'] }
    - { role: isaackehle.mongodb, flags: ['init_replica_set'] }
    - { role: isaackehle.mongodb, flags: ['add_shard_to_cluster'] }
    - { role: isaackehle.mongodb, flags: ['create_database'] }
```

## Linting

```bash
yamllint -c yamllint.yaml .
ansible-lint .
```

## License

MIT

## Author Information

Isaac Kehle
@isaackehle ([twitter](https://twitter.com/isaackehle), [github](https://github.com/isaackehle), [linkedin](https://www.linkedin.com/in/isaackehle))

### References

- MongoDB

  - [Security Hardening](https://docs.mongodb.com/manual/core/security-hardening/)
  - [X509](https://docs.mongodb.com/manual/core/security-x.509/)
  - [Deploy Shard Cluster](https://docs.mongodb.com/manual/tutorial/deploy-shard-cluster/)
  - [Add Shards to Cluster](https://docs.mongodb.com/manual/tutorial/add-shards-to-shard-cluster)
  - [Authorization](https://docs.mongodb.com/manual/core/authorization/)
  - [Internal Auth](https://docs.mongodb.com/manual/core/security-internal-authentication/)
  - [Configure Member Certificates](https://docs.mongodb.com/manual/tutorial/configure-x509-member-authentication/*x509-member-certificate)
  - [Enforce Keyfile Access Control](https://docs.mongodb.com/manual/tutorial/enforce-keyfile-access-control-in-existing-replica-set/)
  - [Deploy Replica Set w/ Keyfill Access Control](https://docs.mongodb.com/v3.2/tutorial/deploy-replica-set-with-keyfile-access-control/)
  - [db.createUser()](https://docs.mongodb.com/manual/reference/method/db.createUser/#db.createUser)
  - [Secure MongoDB With x509](https://www.mongodb.com/blog/post/secure-mongodb-with-x-509-authentication)

- Digital Ocean
  - [Implement Replica Sets on Ubuntu VPS](https://www.digitalocean.com/community/tutorials/how-to-implement-replication-sets-in-mongodb-on-an-ubuntu-vps)
  - [Create a Sharded Cluster 12.04](https://www.digitalocean.com/community/tutorials/how-to-create-a-sharded-cluster-in-mongodb-using-an-ubuntu-12-04-vps)
