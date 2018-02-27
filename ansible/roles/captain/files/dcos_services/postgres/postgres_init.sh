#!/bin/bash

psql -h falcon-deepcortex-c2s-test-redshift.cg9ga2qjlnys.us-gov-west-1.redshift.amazonaws.com -U deepcortex -d dev -p 5439 -c 'create schema test;'
psql -h falcon-deepcortex-c2s-test-redshift.cg9ga2qjlnys.us-gov-west-1.redshift.amazonaws.com -U deepcortex -d dev -p 5439 -c 'create table test.test (id int);'