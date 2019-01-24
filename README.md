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

docker run -p 3306:3306 -e MYSQL_ROOT_PASSWORD=123456 -e MYSQL_REPLICATION_USER=repl -e MYSQL_REPLICAITON_PASSWORD=123456 -d huanwei/mysql-master:0.2

## run slave:

docker run -e MYSQL_ROOT_PASSWORD=123456 -e MYSQL_REPLICATION_USER=repl -e MYSQL_REPLICAITON_PASSWORD=123456 -e MYSQL_MASTER_SERVICE_HOST=127.0.0.1 -d huanwei/mysql-slave:0.2

or (not recommend):

docker run -e MYSQL_ROOT_PASSWORD=123456 -e MYSQL_REPLICATION_USER=repl -e MYSQL_REPLICAITON_PASSWORD=123456 -e MYSQL_MASTER_SERVICE_HOST=127.0.0.1 -d huanwei/mysql-slave:0.1 --read-only=1


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
