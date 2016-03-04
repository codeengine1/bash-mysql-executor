#!/usr/bin/env bash

set -e

directory="$1"
database="$2"
user="$3"
password="$4"

mysql --host=localhost --user="$user" --password="$password" --execute="DROP DATABASE IF EXISTS $database;"
mysql --host=localhost --user="$user" --password="$password" --execute="CREATE DATABASE IF NOT EXISTS $database;"

function mysql_exec {
    mysql --host=localhost --user="$user" --password="$password" --database="$database" < $1
}

function mysql_exec_files {
if ls $1 1> /dev/null 2>&1; then
    for file in `ls $1 | sort -t- -k2,2 -n`; do mysql_exec $file; done;
fi

}

function mysql_exec_env {
    mysql_exec_files "$1/*_ddl_*_$2.sql"
    mysql_exec_files "$1/*_dml_*_$2.sql"
}

# live files first, then rc, then dev
mysql_exec_env $directory "live"
mysql_exec_env $directory "rc"
mysql_exec_env $directory "dev"