# Zoneminder Docker

This is a docker image for Zoneminder that runs the Zoneminder components in a php-fpm
container without a bundled web server or database. The docker-compose.yml file in this
repository is a demo of how this can be deployed together.

## Configuration

- ZM_DB_USER: Username for the database
- ZM_DB_PASS: Database password
- ZM_DB_HOST: Database hostname
