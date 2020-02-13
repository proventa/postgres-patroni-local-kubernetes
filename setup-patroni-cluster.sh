#!/bin/sh

set -x

kubectl create namespace zalando-postgres

kubectl create -f patroni/configmap.yaml -n zalando-postgres

kubectl create -f patroni/operator-service-account-rbac.yaml -n zalando-postgres

kubectl create -f patroni/postgres-operator.yaml -n zalando-postgres

sleep 10

kubectl get pod -l name=postgres-operator -n zalando-postgres

kubectl create -f patroni/postgres-instance.yaml -n zalando-postgres

sleep 10

kubectl get postgresql -n zalando-postgres

kubectl get pods -l application=spilo -L spilo-role -n zalando-postgres

kubectl get svc -l application=spilo -L spilo-role -n zalando-postgres
