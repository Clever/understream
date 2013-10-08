#!/bin/bash
rm -rf node_modules
source ~/nvm/nvm.sh
nvm install 0.10.15
nvm use 0.10.15
npm install
npm test
