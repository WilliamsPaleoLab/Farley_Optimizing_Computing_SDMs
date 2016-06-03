	
#! /bin/bash
#! /bin/bash

sudo apt-get update

sudo apt-get install r-core

sudo apt-get install gdebi-core

wget https://download2.rstudio.org/rstudio-server-0.99.902-amd64.deb

sudo gdebi rstudio-server-0.99.902-amd64.deb

wget https://dl.google.com/cloudsql/cloud_sql_proxy.linux.amd64

mv cloud_sql_proxy.linux.amd64 /home/sfarley2/cloud_sql_proxy

chmod +x /home/sfarley2/cloud_sql_proxy

sudo mkdir /home/sfarley2/cloudsql; sudo chmod 777 /home/sfarley2/cloudsql

rm -rf /home/rstudio/thesis-scripts

git clone http://github.com/scottsfarley93/thesis-scripts /home/rstudio/thesis-scripts

sudo ./home/sfarley2/cloud_sql_proxy -dir=/home/sfarley2/cloudsql -instances=thesis-1329:us-central1:sdm-database-3 &

Rscript /home/rstudio/thesis-scripts/R/time_sdm.R 1 FALSE
