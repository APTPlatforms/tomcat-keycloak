## Apache Tomcat / Keycloak in Docker

Example [docker-compose][docker-compose] configuration for Tomcat 8.5 with Keycloak 4.0

This [Guide][Guide] was tremendously helpful in this configuration.

### Getting Started

#### What You'll Need

The particulars of installing Docker and docker-compose are outside of this
example. We assume that if you've come here looking for a little assistance
that you're already well versed in those concepts.

* [Docker][Docker]
* [docker-compose][docker-compose]
* DNS setup. This example uses [LE][Let's Encrypt] for SSL certificates.
  * Hostnames: traefik, mysql, tomcat, keycloak, wordpress
* Incoming Internet access for Let's Encrypt access.
* Edit .env and change settings

#### Procedure

* Create hosts entries per above.

        docker volume create --name=mysql-data
        docker volume create --name=wordpress-data

* Start Keycloak server. Should take 20-30 seconds.

        docker-compose up -d keycloak

* Wait a bit. Check your logs and wait for Keycloak to come online.

* Login to the master realm in Keycloak. This will save credentials in
`~/.keycloak/kcadm.config` inside the container.

        docker-compose exec keycloak kcadm.sh config credentials \
          --server http://localhost:8080/auth --realm master \
          --user keycloak --password keycloak

* Create the demo realm

        docker-compose exec keycloak kcadm.sh create realms \
          -s realm=tomcat-keycloak -s enabled=true -o

* Create the demo client (for Tomcat application)

        docker-compose exec keycloak kcadm.sh create clients \
          -r tomcat-keycloak \
          -s clientId=tomcat-client \
          -s publicClient=true \
          -s directAccessGrantsEnabled=true \
          -s 'rootUrl=http://tomcat.sofn.aptplatforms.com/tomcat-client' \
          -s 'redirectUris=[ "/roles/*", "/index.html", "/" ]' \
          -i

* Create the demo user and set a temporary password

        docker-compose exec keycloak kcadm.sh create users \
          -r tomcat-keycloak -s username=tester -s enabled=true
    
        docker-compose exec keycloak kcadm.sh set-password \
          -r tomcat-keycloak --username=tester --new-password tester --temporary

* Create the demo roles and assign to the user. Note that we only assign role0
  and role1. role2 is used to show intentional authorization failure.

        docker-compose exec keycloak kcadm.sh create roles -r tomcat-keycloak -s name=role0

        docker-compose exec keycloak kcadm.sh create roles -r tomcat-keycloak -s name=role1

        docker-compose exec keycloak kcadm.sh create roles -r tomcat-keycloak -s name=role2

        docker-compose exec keycloak kcadm.sh add-roles -r tomcat-keycloak --uusername=tester --rolename role0

        docker-compose exec keycloak kcadm.sh add-roles -r tomcat-keycloak --uusername=tester --rolename role1

* Start Tomcat server. Should take 20-30 seconds.

        docker-compose up -d tomcat wordpress

#### CoreOS Customization

This is here to remember the easy to customize CoreOS used in our
[DO][DigitalOcean] environment.

        rm -f .bashrc
        cp ../../usr/share/skel/.bashrc .bashrc
        echo 'set -o vi' >>.bashrc

        sudo mkdir -p /opt/bin
        sudo curl -L https://github.com/docker/compose/releases/download/1.22.0/docker-compose-`uname -s`-`uname -m` -o /opt/bin/docker-compose
        sudo chmod 0755 /opt/bin/docker-compose

        update_engine_client -update

### Things to Note

* Of course I included a script to do all of the commands for you, but where's
  the fun in that? `./deploy.sh` if you're so inclined.

[docker-compose]: https://docs.docker.com/compose/install/
[Docker]: https://www.docker.com/
[Guide]: https://cbfiles.blob.core.windows.net/docs/AGuideforsettingupTomcatwithaStandaloneKeycloakAuthenticationServer.pdf
[LE]: https://letsencrypt.org/
[DO]: https://www.digitalocean.com/
