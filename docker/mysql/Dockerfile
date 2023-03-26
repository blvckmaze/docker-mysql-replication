FROM mysql:8.0.23

COPY my.cnf /etc/my.cnf

RUN mkdir /var/log/mysql \
    && chown -R mysql:mysql /var/log/mysql
