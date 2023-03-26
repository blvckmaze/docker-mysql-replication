# Docker MySQL replication

This project provides a practical example of MySQL database replication using Docker containers. With this setup, you can easily create a replica of a master MySQL database, allowing you to distribute the workload and improve the reliability and availability of your database.

The project includes Docker Compose files that define the configuration of the master and replica MySQL servers, as well as scripts to set up replication. The containers are based on official MySQL images from Docker Hub, and the setup is fully customizable and scalable to fit your specific needs.

Whether you're looking to learn more about MySQL replication or need to implement it in your own project, this repository provides a convenient and comprehensive starting point. Feel free to fork the code, experiment with different configurations, and contribute to the community!

## Requirements

- Install **[docker engine][docker-link]** (20.10.0+) / **[docker compose][docker-compose-link]**.
- To use Docker containers without switching to superuser mode, you will need to add a group for the current system user by running: `sudo usermod -aG docker $USER` <br/>
  Otherwise, you will have to run all Docker commands through the sudo command.

## Usage example

- Build and start the Docker containers by running: `docker compose up -d`
- Wait for the servers to become operational and check the logs by running `docker compose logs -f`.
- Wait for the following line in the output: `[Server] /usr/sbin/mysqld: ready for connections`
- Make the `init.sh` script executable by running: `chmod +x init.sh`
- Start the script that generates the SQL code to initialize replication by running: `bash init.sh`
- Make any changes in the master's database and check if they appear in the slave database.
- At this point, you should have a fully operational MySQL server with replication enabled.

## Environment variables

The project uses the following environment variables, which I highly recommend that you change:

### Master variables (**[.env.master][env-master]**)

| Variable Name       | Default Value | Description                                                                                                                                                                                        |
| ------------------- | ------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| MYSQL_ROOT_PASSWORD | secretpw      | The root password for the MySQL database.                                                                                                                                                          |
| MYSQL_DATABASE      | new_database  | The name of the new database to be created in MySQL. Don't forget to update the `binlog_do_db` attribute value in the **[master config][master-config-binlog]** file to match the value used here. |
| MYSQL_USER          | master_user   | The username to be used for accessing the MySQL server.                                                                                                                                            |
| MYSQL_PASSWORD      | secretpw      | The password for the MySQL user specified in MYSQL_USER.                                                                                                                                           |

### Slave variables (**[.env.slave][env-slave]**)

| Variable Name       | Default Value | Description                                                                                                                                                                                                                                    |
| ------------------- | ------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| MYSQL_ROOT_PASSWORD | secretpw      | The root password for the MySQL database.                                                                                                                                                                                                      |
| MYSQL_DATABASE      | new_database  | The name of the new database to be created in MySQL. Should match master's `MYSQL_DATABASE` value. Don't forget to update the `binlog_do_db` attribute value in the **[slave config][slave-config-binlog]** file to match the value used here. |
| MYSQL_USER          | slave_user    | The username will be used for accessing the MySQL server and for authorization in the master database as a replica user.                                                                                                                       |
| MYSQL_PASSWORD      | secretpw      | The password for the MySQL user specified in MYSQL_USER.                                                                                                                                                                                       |

Additionally, if you prioritize security, it is advisable to modify the `DOCKER_SUBNET_RANGE` variable in the **[init.sh][docker-subnet-range]** script to a reasonable range, like Docker's default: `172.17.0.0/16`

[docker-link]: https://docs.docker.com/engine/install/
[docker-compose-link]: https://docs.docker.com/compose/install/
[docker-subnet-range]: init.sh?plain=1#L6
[master-config-binlog]: docker/mysql/master/my.cnf?plain=1#L12
[slave-config-binlog]: docker/mysql/slave/my.cnf?plain=1#L11
[env-master]: .env.master
[env-slave]: .env.slave
