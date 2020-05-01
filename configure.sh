#! /bin/sh
#
# configure.sh
# Copyright (C) 2020 jiangyc <0599jiangyc@gmail.com>
#
# Distributed under terms of the MIT license.
#
cd backend
npm install
wget "http://127.0.0.1/.env"
cd ..
cd frontend
yarn install  # about 5 mins
