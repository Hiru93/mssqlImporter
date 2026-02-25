#!/bin/bash

# Start the Docker containers
docker-compose up --build --force-recreate --no-deps -d db bo 

# Wait for the import to finish
while ! docker-compose logs | grep -Fq "+++++++++++++++++++++++ DB READY TO EXPORT DATA +++++++++++++++++++++++"
do
  sleep 1
done

echo "@@@@@@@@@@@@@@@@@@@ Containers bootstrap finished, now building the db"
echo "@@@@@@@@@@@@@@@@@@@ DB import finished"
echo "@@@@@@@@@@@@@@@@@@@ Now calling the export API"

# Trigger the API for the DB export and get the HTTP status code
status=$(curl -o /dev/null -s -w "%{http_code}\n" http://localhost:3000/db-dump)

# Check if the API call was successful
if [ $status -eq 200 ]
then
  echo "@@@@@@@@@@@@@@@@@@@ API call was successful"
else
  echo "################### API call failed with status code $status"
  exit 1
fi

# Stop the Docker containers and remove the images
docker-compose down --rmi all

echo "@@@@@@@@@@@@@@@@@@@ Docker containers stopped and images removed"