\connect postgres
create database bitnami_keycloak;
create role bn_keycloak with encrypted password 'secret' LOGIN;

\connect bitnami_keycloak
grant all privileges on schema public to bn_keycloak;