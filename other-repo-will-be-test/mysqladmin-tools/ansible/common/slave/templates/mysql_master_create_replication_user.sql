SET SQL_LOG_BIN=0;
create user {{mysql_repl_user}}@'%' identified by '{{mysql_repl_password}}';
grant replication slave,replication client on *.* to {{mysql_repl_user}}@'%';
SET SQL_LOG_BIN=1;