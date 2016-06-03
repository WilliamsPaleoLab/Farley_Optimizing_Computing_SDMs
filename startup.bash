	
#! /bin/bash
sudo mkdir /home/sfarley2/cloudsql; sudo chmod 777 /home/sfarley2/cloudsql

sudo ./home/sfarley2/cloud_sql_proxy -dir=/home/sfarley2/cloudsql -instances=thesis-1329:us-central1:sdm-database-3 &

Rscript /home/rstudio/thesis-scripts/R/time_sdm.R 1 TRUE
