psql template1
CREATE USER floodlight WITH PASSWORD 'floodlight';
CREATE DATABASE floodlight;
GRANT ALL PRIVILEGES ON DATABASE floodlight to floodlight;
\q

exit
