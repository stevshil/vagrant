#!/bin/expect -f

spawn su - postgres
expect "$ "
send "psql -h localhost puppetdb puppetdb\r"
expect "Password for user puppetdb:"
send "secret\r"
expect "puppetdb=>"
send "\\q\r"
