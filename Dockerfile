FROM tomcat:8.5-jre10
LABEL maintainer="Chris Cosby <chris.cosby@aptplatforms.com>"

ARG keycloak_version=4.0.0.Beta3

ADD https://downloads.jboss.org/keycloak/${keycloak_version}/adapters/keycloak-oidc/keycloak-tomcat8-adapter-dist-${keycloak_version}.tar.gz /keycloak-tomcat8-adapter-dist-${keycloak_version}.tar.gz

RUN tar -C /usr/local/tomcat/lib -xzf /keycloak-tomcat8-adapter-dist-${keycloak_version}.tar.gz \
 && rm -f /keycloak-tomcat8-adapter-dist-${keycloak_version}.tar.gz

# vim: set filetype=dockerfile :
