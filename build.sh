#!/bin/sh

docker volume create --name=tomcat-keycloak-pgdata

docker-compose up -d keycloak

sleep 30

docker-compose exec keycloak kcadm.sh config credentials \
  --server http://localhost:8080/auth --realm master \
  --user keycloak --password keycloak

docker-compose exec keycloak kcadm.sh create realms \
  -s realm=tomcat-keycloak -s enabled=true -o

docker-compose exec keycloak kcadm.sh create clients \
  -r tomcat-keycloak \
  -s clientId=keycloak-demo-client \
  -s publicClient=true \
  -s directAccessGrantsEnabled=true \
  -s 'rootUrl=http://tomcat.site.example.com:8080/keycloak-demo-client' \
  -s 'redirectUris=[ "/roles/*", "/index.html", "/" ]' \
  -i

docker-compose exec keycloak kcadm.sh create users \
  -r tomcat-keycloak -s username=tester -s enabled=true

docker-compose exec keycloak kcadm.sh set-password \
  -r tomcat-keycloak --username=tester --new-password tester --temporary

docker-compose exec keycloak kcadm.sh create roles -r tomcat-keycloak -s name=role0

docker-compose exec keycloak kcadm.sh create roles -r tomcat-keycloak -s name=role1

docker-compose exec keycloak kcadm.sh create roles -r tomcat-keycloak -s name=role2

docker-compose exec keycloak kcadm.sh add-roles -r tomcat-keycloak --uusername=tester --rolename role0

docker-compose exec keycloak kcadm.sh add-roles -r tomcat-keycloak --uusername=tester --rolename role1

docker-compose up -d tomcat

sleep 20

echo "Go here!  http://tomcat.site.example.com:8080/keycloak-demo-client/"
