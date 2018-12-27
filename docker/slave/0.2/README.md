
## optimized for slave, set `read_only ` as `ON` default for non-super users.
```
mysql> show variables like '%read_only%';
+-----------------------+-------+
| Variable_name         | Value |
+-----------------------+-------+
| innodb_read_only      | OFF   |
| read_only             | ON    |
| super_read_only       | OFF   |
| transaction_read_only | OFF   |
| tx_read_only          | OFF   |
+-----------------------+-------+
5 rows in set (0.01 sec)
```

If we set `super_read_only` as `ON`, the mysql slave pod will catch error, like below:

```
2018-12-27T14:01:28.766129Z 0 [Note] mysqld: ready for connections.
Version: '5.7.22-log'  socket: '/var/run/mysqld/mysqld.sock'  port: 0  MySQL Community Server (GPL)
ERROR 1290 (HY000) at line 1: The MySQL server is running with the --super-read-only option so it cannot execute this statement

```

So we will have to run `set global super_read_only=1;` on slave pods in case super user's CRUD operations to the tables, which will impact the master-slaves replication.