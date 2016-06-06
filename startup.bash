#! /bin/bash

sudo apt-get update

sudo apt-get -y install git

sudo apt-get -y install r-base

sudo apt-get install -y gdebi-core

sudo apt-get install -y aptitude

sudo aptitude install -y libgdal-dev 

sudo aptitude install -y libproj-dev

sudo apt-get install -y  libmariadb-client-lgpl-dev 

wget https://download2.rstudio.org/rstudio-server-0.99.902-amd64.deb

sudo gdebi -y rstudio-server-0.99.902-amd64.deb

wget https://dl.google.com/cloudsql/cloud_sql_proxy.linux.amd64

mv cloud_sql_proxy.linux.amd64 cloud_sql_proxy

chmod +x cloud_sql_proxy

sudo mkdir cloudsql; sudo chmod 777 cloudsql

rm -rf /home/rstudio/thesis-scripts

git clone http://github.com/scottsfarley93/thesis-scripts /home/rstudio/thesis-scripts

sudo ./cloud_sql_proxy  -dir=/cloudsql -instances=thesis-1329:us-central1:sdm-database-3 &

cat <<EOF > /home/rstudio/thesis-scripts/R/config.R
EOF

cat <<EOF > /home/keys.txt
EOF

cat <<EOF > /host.txt
EOF

Rscript /home/rstudio/thesis-scripts/R/time_sdm.R 50 TRUE
