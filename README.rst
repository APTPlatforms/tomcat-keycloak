Apache Tomcat / Keycloak in Docker
==================================

Example `docker-compose`_ configuration for Tomcat 8.5 with Keycloak 4.0

This `Guide`_ was tremendously helpful in this configuration.

Getting Started
---------------

What You'll Need
~~~~~~~~~~~~~~~~

The particulars of installing Docker and docker-compose are outside of this
example. We assume that if you've come here looking for a little assistance
that you're already well versed in those concepts.

* `Docker`_
* `docker-compose`_
* An entry in your ``/etc/hosts`` or ``C:\windows\system32\drivers\etc\hosts`` for
  the hosts used in this example
  .. code:: console

    ``127.0.0.1 localhost {{etc. etc.}} keycloak.site.example.com tomcat.site.example.com``

Procedure
~~~~~~~~~

* Create hosts entries per above.

  .. code:: console

    docker volume create --name=mysql-data
    docker volume create --name=wordpress-data

* Start Keycloak server. Should take 20-30 seconds.

  .. code:: console

    docker-compose up -d keycloak

* Wait a bit. Check your logs and wait for Keycloak to come online.

* Login to the master realm in Keycloak. This will save credentials in
  ``~/.keycloak/kcadm.config``

  .. code:: console

    docker-compose exec keycloak kcadm.sh config credentials \
      --server http://localhost:8080/auth --realm master \
      --user keycloak --password keycloak

* Create the demo realm

  .. code:: console

    docker-compose exec keycloak kcadm.sh create realms \
      -s realm=tomcat-keycloak -s enabled=true -o

* Create the demo client (application)

  .. code:: console

    docker-compose exec keycloak kcadm.sh create clients \
      -r tomcat-keycloak \
      -s clientId=tomcat-client \
      -s publicClient=true \
      -s directAccessGrantsEnabled=true \
      -s 'rootUrl=http://tomcat.site.example.com:8080/tomcat-client' \
      -s 'redirectUris=[ "/roles/*", "/index.html", "/" ]' \
      -i

* Create the demo user and set a temporary password

  .. code:: console

    docker-compose exec keycloak kcadm.sh create users \
      -r tomcat-keycloak -s username=tester -s enabled=true

    docker-compose exec keycloak kcadm.sh set-password \
      -r tomcat-keycloak --username=tester --new-password tester --temporary

* Create the demo roles and assign to the user. Note that we only assign role0
  and role1. role2 is used to show intentional authorization failure.

  .. code:: console

    docker-compose exec keycloak kcadm.sh create roles -r tomcat-keycloak -s name=role0

    docker-compose exec keycloak kcadm.sh create roles -r tomcat-keycloak -s name=role1

    docker-compose exec keycloak kcadm.sh create roles -r tomcat-keycloak -s name=role2

    docker-compose exec keycloak kcadm.sh add-roles -r tomcat-keycloak --uusername=tester --rolename role0

    docker-compose exec keycloak kcadm.sh add-roles -r tomcat-keycloak --uusername=tester --rolename role1

* Start Tomcat server. Should take 20-30 seconds.

  .. code:: console

    docker-compose up -d tomcat wordpress

* Open your browser to `Tomcat Site`_ and `WordPress Site`_

Things to Note
--------------

* The TCP ports are weird when you're dealing with containers. I had to run
  the frontend proxy on the same port as the containers. You can probably
  proxy to the proxy to deal with it (like if you want Let's Encrypt or
  something similar). The ultimate problem is that your client needs to
  communicate with the FQDN, which would be fine, but the servers talk to each
  other as well. And they specify ports. I might try to work around this one
  day.

* Of course I included a script to do all of the commands for you, but where's
  the fun in that? ``./deploy.sh`` if you're so inclined.

.. _Tomcat Site: http://tomcat.site.example.com:8080/tomcat-client/
.. _WordPress Site: http://wordpress.site.example.com:8080/
.. _docker-compose: https://docs.docker.com/compose/install/
.. _Docker: https://www.docker.com/
.. _Guide: https://cbfiles.blob.core.windows.net/docs/AGuideforsettingupTomcatwithaStandaloneKeycloakAuthenticationServer.pdf
