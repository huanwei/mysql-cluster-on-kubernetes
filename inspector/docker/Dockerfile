# huanwei/mysql-inspector:0.1
FROM huanwei/mysql-master:0.2
MAINTAINER Huan Wei<huan@harmonycloud.cn>

RUN apt-get update && apt-get install -y mailutils
COPY mail.rc /etc/mail.rc

COPY inspector.sh /
RUN chmod +x /inspector.sh
ENTRYPOINT ["/inspector.sh"]