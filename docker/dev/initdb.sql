\connect postgres
create database providentia_test;
create database keycloak;
create role keycloak with encrypted password 'secret' LOGIN;

\connect keycloak
grant all privileges on schema public to keycloak;