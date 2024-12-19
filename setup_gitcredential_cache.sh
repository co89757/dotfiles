#!/usr/bin/env bash
## set up git credential helper and change cache timeout
git config --global credential.credentialStore cache
# set timeout to 6h
git config --global credential.cacheOptions '--timeout=21600'
