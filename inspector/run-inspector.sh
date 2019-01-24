#!/bin/bash

rm -rf ./data
docker run -d -v `pwd`/data/tmp:/tmp huanwei/mysql-inspector:0.1