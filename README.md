# mysql-cluster-on-kubernetes
This is a sample MySQL cluster on Kubernetes.

The original MySQL5.7 image Dockerfile came from [docker-library/mysql](https://github.com/huanwei/mysql/tree/master/5.7).

Just made some addtions to operate the MySQL cluster on kubernetes.

## how to validate: 
```

[root@k8s-master no-operator]# kubectl get pods -owide
NAME                                  READY     STATUS    RESTARTS   AGE       IP               NODE
mysql-master-lzzps                    1/1       Running   0          47m       192.168.196.8    k8s-node5
mysql-slave-jrrs9                     1/1       Running   0          2m        192.168.36.137   k8s-node1
tomcat-deployment-67b98b747b-b62l6    1/1       Running   0          41d       192.168.108.1    k8s-node3
tomcat-hostnetwork-78cc6766f6-4bmz8   1/1       Running   0          41d       10.10.103.184    k8s-node2
tomcat-victim-7fdb76db44-nxvg5        1/1       Running   0          39d       192.168.36.129   k8s-node1


mysql maser:

[root@k8s-master no-operator]# kubectl exec -it mysql-master-lzzps bash
root@mysql-master-lzzps:/# mysql -u root -p

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

root@mysql-slave-jrrs9:/# mysql -u root -p

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

[root@k8s-master no-operator]# kubectl scale rc mysql-slave --replicas=3
replicationcontroller "mysql-slave" scaled
[root@k8s-master no-operator]# kubectl get pods -owide
NAME                                  READY     STATUS    RESTARTS   AGE       IP                NODE
mysql-master-lzzps                    1/1       Running   0          56m       192.168.196.8     k8s-node5
mysql-slave-jrrs9                     1/1       Running   0          11m       192.168.36.137    k8s-node1
mysql-slave-wfnms                     1/1       Running   0          1m        192.168.108.19    k8s-node3
mysql-slave-z4rm9                     1/1       Running   0          1m        192.168.122.134   k8s-node4

```
