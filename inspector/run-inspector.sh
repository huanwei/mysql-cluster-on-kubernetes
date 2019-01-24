#!/bin/bash

docker run -d -v `pwd`/data/tmp:/tmp huanwei/mysql-inspector:0.1
