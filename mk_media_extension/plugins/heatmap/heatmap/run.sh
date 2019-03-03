#!/bin/bash

current_dir=$1
port=$2

# Change working directory
cd ${current_dir}

echo "Port: $2"
R -e "shiny::runApp(appDir = './', port = ${port})"

echo "The shiny app (${current_dir}) is running..."