#!/bin/bash

pcs cluster destroy
echo "hacluster:Temporal01" | chpasswd
pcs host auth spongebob patrick -u hacluster -p Temporal01
pcs cluster setup storage spongebob patrick --start --enable --force

