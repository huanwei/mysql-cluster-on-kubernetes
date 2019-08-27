# mysql-cluster-on-kubernetes
This is a sample MySQL cluster on Kubernetes.

The original MySQL5.7 image Dockerfile came from [docker-library/mysql](https://github.com/huanwei/mysql/tree/master/5.7).

Just made some additions to operate the MySQL cluster on kubernetes.

## how to validate: 

```
[root@k8s-master deployment]# kubectl get pods -owide |grep mysql
mysql-master-764955b95-9d2ch          1/1       Running       0          3m        192.168.36.153    k8s-node1
mysql-slave-67d75fd689-7q56w          1/1       Running       0          30s       192.168.169.207   k8s-node2


mysql maser:

[root@k8s-master deployment]# kubectl exec -it mysql-master-764955b95-9d2ch bash
root@mysql-master-764955b95-9d2ch:/# mysql -u root -p

mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| sys                |
+--------------------+
4 rows in set (0.00 sec)

mysql> 
mysql> create database huan_test_sync_db;
Query OK, 1 row affected (0.00 sec)

mysql> use huan_test_sync_db;
Database changed
mysql> create table test_tb(id int(3),name char(10)); insert into test_tb values(001,'ok');
Query OK, 0 rows affected (0.00 sec)

Query OK, 1 row affected (0.02 sec)

mysql> select * from test_tb;
+------+------+
| id   | name |
+------+------+
|    1 | ok   |
+------+------+
1 row in set (0.00 sec)

mysql slave:

root@mysql-slave-67d75fd689-7q56w:/# mysql -u root -p

mysql> show slave status;

mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| huan_test_sync_db  |
| mysql              |
| performance_schema |
| sys                |
+--------------------+
5 rows in set (0.00 sec)

mysql> use huan_test_sync_db;
Reading table information for completion of table and column names
You can turn off this feature to get a quicker startup with -A

Database changed
mysql> show tables;
+-----------------------------+
| Tables_in_huan_test_sync_db |
+-----------------------------+
| test_tb                     |
+-----------------------------+
1 row in set (0.00 sec)

mysql> select * from test_tb;
+------+------+
| id   | name |
+------+------+
|    1 | ok   |
+------+------+
1 row in set (0.00 sec)

[root@k8s-master deployment]# kubectl scale deploy mysql-slave --replicas=3
deployment "mysql-slave" scaled

[root@k8s-master deployment]# kubectl get pods -owide |grep mysql
mysql-master-764955b95-9d2ch          1/1       Running       0          3m        192.168.36.153    k8s-node1
mysql-slave-67d75fd689-7q56w          1/1       Running       0          30s       192.168.169.207   k8s-node2
mysql-slave-67d75fd689-plz6z          1/1       Running       0          1m        192.168.169.206   k8s-node2
mysql-slave-67d75fd689-sgr5g          1/1       Running       0          30s       192.168.36.154    k8s-node1

```

## FAQ
### 1. how to check slave status

```
mysql> SHOW SLAVE STATUS\G;
```

### 2. to set slave read-only
```
mysql> set global read_only=1;
mysql> set global super_read_only=1;

mysql> show global variables like "%read_only%";
+-----------------------+-------+
| Variable_name         | Value |
+-----------------------+-------+
| innodb_read_only      | OFF   |
| read_only             | ON    |
| super_read_only       | ON    |
| transaction_read_only | OFF   |
| tx_read_only          | OFF   |
+-----------------------+-------+
5 rows in set (0.01 sec)
```

### 3. to lock db before backup
```
mysql> flush tables with read lock;
```


### 4. to see a complete list of available options
```
docker run -it -e MYSQL_ROOT_PASSWORD=123456 huanwei/mysql-slave:0.1 --verbose --help

## refer https://github.com/docker-library/docs/tree/master/mysql

## run master:

docker run -p 3306:3306 -e MYSQL_ROOT_PASSWORD=123456 -e MYSQL_REPLICATION_USER=repl -e MYSQL_REPLICAITON_PASSWORD=123456 -d huanwei/mysql-master:0.3

## run slave:

docker run -e MYSQL_ROOT_PASSWORD=123456 -e MYSQL_REPLICATION_USER=repl -e MYSQL_REPLICAITON_PASSWORD=123456 -e MYSQL_MASTER_SERVICE_HOST=192.168.31.95 -d huanwei/mysql-slave:0.3

(### Please note that the above 192.168.31.95 must be the IP address of MySQL master node)


or (not recommend):

docker run -e MYSQL_ROOT_PASSWORD=123456 -e MYSQL_REPLICATION_USER=repl -e MYSQL_REPLICAITON_PASSWORD=123456 -e MYSQL_MASTER_SERVICE_HOST=192.168.31.95 -d huanwei/mysql-slave:0.1 --read-only=1


## to test if we can optimize a talbe in mysql slave 

mysql>  optimize table default_table;

```

### how to increase max_allowed_packet for master
```

show variables like '%max_allowed%';

//set global max_allowed_packet=20971520; //20M
set global max_allowed_packet=1073741824;//1G

```

### how to modify time_zone 
```
set global time_zone = '+8:00';
flush privileges; 

mysql> show variables like '%time_zone%';
+------------------+--------+
| Variable_name    | Value  |
+------------------+--------+
| system_time_zone | CST    |
| time_zone        | +08:00 |
+------------------+--------+
2 rows in set (0.00 sec)

```

### remove `ONLY_FULL_GROUP_BY`

In some scenarios user would use `group by` in sql clause, it will prompt errors during to the default setting of sql_mode.

```
mysql> SELECT @@sql_mode;
+-------------------------------------------------------------------------------------------------------------------------------------------+
| @@sql_mode                                                                                                                                |
+-------------------------------------------------------------------------------------------------------------------------------------------+
| ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION |
+-------------------------------------------------------------------------------------------------------------------------------------------+
1 row in set (0.00 sec)

mysql> 

```

So I remove this since version 0.3.

```
mysql> SELECT @@sql_mode;
+-------------------------------------------------------------------------------------------------------------------------------------------+
| @@sql_mode                                                                                                                                |
+-------------------------------------------------------------------------------------------------------------------------------------------+
| STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION |
+-------------------------------------------------------------------------------------------------------------------------------------------+
1 row in set (0.00 sec)

mysql> 
```

## how to upgrade root password

### first, login mysql and do following
```
mysql> use mysql;
Reading table information for completion of table and column names
You can turn off this feature to get a quicker startup with -A

Database changed
mysql> update user set authentication_string=password('root123') where user='root';
Query OK, 2 rows affected, 1 warning (0.01 sec)
Rows matched: 2  Changed: 2  Warnings: 1

mysql> flush privileges;
Query OK, 0 rows affected (0.00 sec)

mysql> quit
Bye

```
### second, change the password in docker startup environments.(this is optional)
