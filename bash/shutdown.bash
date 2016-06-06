#!/bin/bash

MY_PROGRAM="Rscript"
MY_USER="sfarley2"
HOSTNAME = $(hostname)

echo "Shutting down!  Seeing if ${MY_PROGRAM} is running."

# Find the newest copy of $MY_PROGRAM
PID="$(pgrep -n "$MY_PROGRAM")"

if [[ "$?" -ne 0 ]]; then
  echo "${MY_PROGRAM} not running, shutting down immediately."
  exit 0
fi

echo "Sending SIGINT to $PID"
kill -2 "$PID"

# Portable waitpid equivalent
while kill -0 "$PID"; do
   sleep 1
done

echo "$PID is done."

python /home/rstudio/thesis-scripts/python/shutdown.py

echo "Done uploading, shutting down."
