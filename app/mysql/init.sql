CREATE DATABASE IF NOT EXISTS guacamole;

CREATE USER IF NOT EXISTS 'guacamole'@'localhost' IDENTIFIED BY 'guacamole';
GRANT ALL ON `guacamole`.* to 'guacamole'@'localhost';

CREATE USER IF NOT EXISTS 'guacamole'@'127.0.0.1' IDENTIFIED BY 'guacamole';
GRANT ALL ON `guacamole`.* to 'guacamole'@'127.0.0.1';
