## check `max_allowed_packet`

```
root@8ca49a528afa:/# mysqladmin --protocol tcp -uroot -p123456 variables|grep max_allowed_packet |awk '{print $4}'
mysqladmin: [Warning] Using a password on the command line interface can be insecure.
1073741824
1073741824
```

## check remote `max_allowed_packet`
```
root@8ca49a528afa:/# mysqladmin --protocol tcp -h150.223.23.21 -uroot -p123456 variables|grep max_allowed_packet |awk '{print $4}'|sed -n 1p >> remote.txt
mysqladmin: [Warning] Using a password on the command line interface can be insecure.
root@8ca49a528afa:/# 
root@8ca49a528afa:/# cat remote.txt 
1073741824

```

### ref

https://www.cnblogs.com/linux-wang/p/8142844.html


### dingding

```
curl 'https://oapi.dingtalk.com/robot/send?access_token=67cbf102552257c0cd45a10855589048a83cb012077a3e13a4f4a7fefc6ef4eb' \
   -H 'Content-Type: application/json' \
   -d "
  {\"msgtype\": \"text\", 
    \"text\": {
        \"content\": \"消息内容: $Message\"
     }
  }"


```