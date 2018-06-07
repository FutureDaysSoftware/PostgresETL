#!/usr/bin/env bash

now=$(date +"%T")
echo "Starting nightly backup: $now"
pg_dump -h 192.168.168.12 -U ample_production_readonly -d aocore_production -Fc -x -O > ~/prodDump
now=$(date +"%T")
echo "Backup finished, starting copy: $now"
scp -i ~/cbaronsmacbook2017.pem ~/prodDump ubuntu@35.182.206.69:/home/ubuntu/nightlyDump
now=$(date +"%T")
echo "Finished copy: $now"
