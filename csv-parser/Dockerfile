# Use an official Python runtime as a parent image
FROM python:3.8-slim-buster

# Set the working directory in the container to /app
WORKDIR /app/

# Add parent directory files to the container at /app
COPY --chown=1001 csv-parser/export_parsing.sh ./
COPY --chown=1001 csv-parser/archives ./archives
RUN mkdir -p ./archives/extraction-folder
COPY --chown=1001 csv-parser/parsed-files ./parsed-files


# Give execute permissions to your script
RUN chmod +x export_parsing.sh

# Install any needed packages specified in requirements.txt
RUN pip install --no-cache-dir csvkit

# Install unzip and unrar
RUN apt-get update && apt-get install -y unzip
RUN apt-get update && apt-get install -y enca
RUN apt-get update && apt-get install -y file
RUN apt-get update && apt-get install -y uchardet

# Run tail -f /dev/null when the container launches to keep it running
ENTRYPOINT ./export_parsing.sh && tail -f /dev/null