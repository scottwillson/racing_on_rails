drop database if exists racing_on_rails_development;
create database racing_on_rails_development;
grant all privileges on racing_on_rails_development.* to 'ror_development'@'localhost';
drop database if exists racing_on_rails_test;
create database racing_on_rails_test;
grant all privileges on racing_on_rails_test.* to 'ror_test'@'localhost';
