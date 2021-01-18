#!/bin/bash
HOST=$1
OS=${HOST:0:4}
ansible all -i localhost, -c local -m template -a "src=${OS}.conf.j2 dest=./${HOST}_generated.conf" --extra-vars=@host_vars/${HOST}.yaml && cat ${HOST}_generated.conf

