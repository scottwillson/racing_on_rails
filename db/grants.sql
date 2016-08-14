create user if not exists 'ror_development'@'localhost';
create user if not exists 'ror_test'@'localhost';

grant all privileges on racing_on_rails_development.* to 'ror_development'@'localhost';
grant all privileges on `racing_on_rails_test`.* to 'ror_test'@'localhost';
