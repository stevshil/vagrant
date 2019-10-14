#!/bin/expect -f

spawn su - postgres
expect "$ "
send "createuser -DRSP puppetdb\r"
expect "Enter password for new role:"
send "secret\r"
expect "Enter it again:"
send "secret\r"
expect "$ "
send "createdb -E UTF8 -O puppetdb puppetdb\r"
expect "$ "
send "psql -c 'create extension pg_trgm' puppetdb\r"
expect "$ "
send "exit\r"
