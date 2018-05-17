create user if not exists 'ror_development'@'localhost';
create user if not exists 'ror_test'@'localhost';

grant all privileges on racing_on_rails_development_pt.* to 'ror_development'@'localhost';
grant all privileges on `racing_on_rails_test_pt%`.* to 'ror_test'@'localhost';
