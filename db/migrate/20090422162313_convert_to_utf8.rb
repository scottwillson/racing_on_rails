# Ensure your MySQL charset and collation defaults are set to utf8 and utf8_unicode_ci
class ConvertToUtf8 < ActiveRecord::Migration
  def self.up
    db_config = ActiveRecord::Base.connection.instance_values["config"]
    db_name = db_config[:database]
    db_user = db_config[:username]
    db_pass = db_config[:password] || ''
    
    latin1_dump = 'latin1_dump.sql'
    utf8_dump   = 'utf8_dump.sql'
    
    say "Dumping database... "
    system "mysqldump --user=#{db_user} --password='#{db_pass}' --add-drop-table --default-character-set=latin1 --insert-ignore --skip-set-charset #{db_name} > #{latin1_dump}"
    say "done"
    
    say "Converting dump to UTF8... "    
    system "iconv -f ISO-8859-1 -t UTF-8 #{latin1_dump} | sed 's/latin1/utf8/' > #{utf8_dump}"
    say "done"
    
    say "Recreating database..."
    system "mysql --user=#{db_user} --password='#{db_pass}' --execute=\"DROP DATABASE #{db_name};\""
    system "mysql --user=#{db_user} --password='#{db_pass}' --execute=\"CREATE DATABASE #{db_name} CHARACTER SET utf8 COLLATE utf8_unicode_ci;\""
    say "done"
    
    say "Importing UTF8 dump..."
    system "mysql --user=#{db_user} --password='#{db_pass}' --default-character-set=utf8 #{db_name} < #{utf8_dump}"
    say "done"
    
    # What could possibly go wrong?
    say "Recreating test database..."
    test_db_name = db_name.gsub("development", "test")
    test_db_user = db_user.gsub("development", "test")
    test_db_pass = db_pass
    system "mysql --user=#{test_db_user} --password='#{test_db_pass}' --execute=\"DROP DATABASE #{test_db_name};\""
    system "mysql --user=#{test_db_user} --password='#{test_db_pass}' --execute=\"CREATE DATABASE #{test_db_name} CHARACTER SET utf8 COLLATE utf8_unicode_ci;\""
    say "done"
    
    say " *** don't forget to delete temp files #{latin1_dump} and #{utf8_dump}"
  end

  def self.down
    raise "cant revert sorry"
  end
end
