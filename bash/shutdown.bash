#!/bin/bash

MY_PROGRAM="Rscript"
MY_USER="sfarley2"
HOSTNAME = $(hostname)

echo "Shutting down!"
python /home/rstudio/thesis-scripts/python/shutdown.py

echo "Done uploading, shutting down."
echo "Successfully executed shutdown script."
