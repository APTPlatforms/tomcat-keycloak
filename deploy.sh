#!/bin/sh

docker-compose down

docker volume rm mysql-data
docker volume rm wordpress-data

docker volume create --name=mysql-data
docker volume create --name=wordpress-data

docker-compose up -d keycloak

printf 'Waiting for Keycloak to come online'
while :
do
    docker-compose logs keycloak 2>&1 | grep -q -F 'WFLYSRV0051: Admin console listening on http' && break
    printf '.'
    sleep 1
done
echo

docker-compose exec keycloak kcadm.sh config credentials \
  --server http://localhost:8080/auth --realm master \
  --user keycloak --password keycloak

docker-compose exec keycloak kcadm.sh create realms \
  -s realm=tomcat-keycloak -s enabled=true -o

docker-compose exec keycloak kcadm.sh create clients \
  -r tomcat-keycloak \
  -s clientId=tomcat-client \
  -s publicClient=true \
  -s directAccessGrantsEnabled=true \
  -s 'rootUrl=http://tomcat.site.example.com:8080/tomcat-client' \
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

docker-compose up -d tomcat wordpress

sleep 20

cat <<_EOT_
Links:
  http://tomcat.site.example.com:8080/tomcat-client/
  http://wordpress.site.example.com:8080/
_EOT_
