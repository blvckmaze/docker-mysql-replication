CREATE USER ''@'' IDENTIFIED WITH mysql_native_password BY '';
GRANT REPLICATION SLAVE ON *.* TO ''@'';
FLUSH PRIVILEGES;
