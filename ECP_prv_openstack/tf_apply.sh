#!/bin/bash

sript_start_time=$(date +%s)

terraform init
terraform apply -auto-approve || (sleep 5;terraform apply -auto-approve)

sript_end_time=$(date +%s);script_runtime=$(((sript_end_time-sript_start_time)/60))
echo "Runtime in minutes : " $script_runtime
