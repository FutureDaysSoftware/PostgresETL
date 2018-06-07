#!/usr/bin/env bash

now=$(date +"%T")
echo "Starting nightly restore -- checking dump: $now"
OUTPUT=$(pg_restore /home/ubuntu/nightlyDump 2>&1 > /dev/null)
if [[ $OUTPUT =~ "could not uncompress data" ]]
then
  now=$(date +"%T")
  echo "Could not uncompress dump! Done $now"
else
  latestDumpSize=$(stat -c%s /home/ubuntu/nightlyDump)
  latestLegitDumpSize=$(stat -c%s /home/ubuntu/nightlyDumpLegit)
  if [[ "$latestDumpSize" -lt "$latestLegitDumpSize" ]];
  then
    now=$(date +"%T")
    echo "Most recent dump smaller than latest legit.  Doing nothing. $now"
  else
    mv /home/ubuntu/nightlyDump /home/ubuntu/nightlyDumpLegit
    now=$(date +"%T")
    echo "Dump verified -- remove dbconnections, drop database, create database, alter read only role $now"
    psql -d postgres -c "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = 'maricann_reporting';"
    psql -d postgres -c "DROP DATABASE maricann_reporting;"
    psql -d postgres -c "CREATE DATABASE maricann_reporting;"
    psql -d maricann_reporting -c "GRANT SELECT ON ALL TABLES IN SCHEMA public TO readonly;"
    psql -d maricann_reporting -c "ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO readonly;"
    now=$(date +"%T")
    echo "Starting restore: $now"
    pg_restore -d maricann_reporting -x -O /home/ubuntu/nightlyDumpLegit
    now=$(date +"%T")
    echo "Done restoring: $now"
  fi
fi
