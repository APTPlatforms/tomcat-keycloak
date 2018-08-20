FROM tomcat:8.5-alpine
LABEL maintainer="Chris Cosby <chris.cosby@aptplatforms.com>"

ARG KEYCLOAK_VERSION=4.0.0.Final

ADD https://downloads.jboss.org/keycloak/${KEYCLOAK_VERSION}/adapters/keycloak-oidc/keycloak-tomcat8-adapter-dist-${KEYCLOAK_VERSION}.tar.gz /keycloak-tomcat8-adapter-dist-${KEYCLOAK_VERSION}.tar.gz

RUN tar -C /usr/local/tomcat/lib -xzf /keycloak-tomcat8-adapter-dist-${KEYCLOAK_VERSION}.tar.gz \
 && rm -f /keycloak-tomcat8-adapter-dist-${KEYCLOAK_VERSION}.tar.gz
