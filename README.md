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
