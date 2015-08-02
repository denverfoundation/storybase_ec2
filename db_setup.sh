psql template1 -f file -c "CREATE USER floodlight WITH PASSWORD 'floodlight'"
psql template1 -f file -c "CREATE DATABASE floodlight"
psql template1 -f file -c "GRANT ALL PRIVILEGES ON DATABASE floodlight to floodlight"

exit
