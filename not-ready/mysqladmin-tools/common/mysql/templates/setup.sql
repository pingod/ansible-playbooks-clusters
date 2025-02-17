-- 不产生binlog
SET SQL_LOG_BIN = 0;

-- 修改 root 密码
-- alter user user() identified by '{{mysql_password}}';
SET PASSWORD FOR 'root'@'localhost' = PASSWORD('{{mysql_password}}');

delete from mysql.user where `user`!='root' or host != 'localhost';
flush privileges;

-- 创建 admin 用户
create user 'admin'@'%' identified by '{{mysql_password}}';
grant all on *.* to 'admin'@'%' with GRANT OPTION;

-- 创建 app 用户
create user 'app{{mysql_port}}'@'%' identified by '{{mysql_password}}';
grant select,insert,update,delete,index,create,drop,alter on *.* to 'app{{mysql_port}}'@'%';
grant TRIGGER,EXECUTE  on *.* to 'app{{mysql_port}}'@'%';

SET SQL_LOG_BIN = 1;