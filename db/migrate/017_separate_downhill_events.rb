class SeparateDownhillEvents < ActiveRecord::Migration
  def self.up
    if ASSOCIATION.short_name == 'OBRA'
      ids = [6134, 6149, 6151, 6154, 6156, 6016, 6015, 6018, 6019, 6017, 6020]
      for event in Event.find(ids)
        event.discipline = 'Downhill'
        event.save!
      end

      Event.connection.execute('insert into discipline_bar_categories(discipline_id, category_id) values(3, 14)') 
      Event.connection.execute('insert into discipline_bar_categories(discipline_id, category_id) values(3, 15)') 
      Event.connection.execute('insert into discipline_bar_categories(discipline_id, category_id) values(3, 16)') 
      Event.connection.execute('insert into discipline_bar_categories(discipline_id, category_id) values(3, 17)') 
      Event.connection.execute('insert into discipline_bar_categories(discipline_id, category_id) values(3, 18)') 
      Event.connection.execute('insert into discipline_bar_categories(discipline_id, category_id) values(3, 19)') 
      Event.connection.execute('insert into discipline_bar_categories(discipline_id, category_id) values(3, 20)') 
      Event.connection.execute('insert into discipline_bar_categories(discipline_id, category_id) values(3, 22)') 
      Event.connection.execute('insert into discipline_bar_categories(discipline_id, category_id) values(3, 24)') 
      Event.connection.execute('insert into discipline_bar_categories(discipline_id, category_id) values(3, 25)') 
      Event.connection.execute('insert into discipline_bar_categories(discipline_id, category_id) values(3, 26)') 
      Event.connection.execute('insert into discipline_bar_categories(discipline_id, category_id) values(3, 27)') 
      Event.connection.execute('insert into discipline_bar_categories(discipline_id, category_id) values(3, 28)') 
      Event.connection.execute('insert into discipline_bar_categories(discipline_id, category_id) values(3, 29)') 
      Event.connection.execute('insert into discipline_bar_categories(discipline_id, category_id) values(3, 30)') 
      Event.connection.execute('insert into discipline_bar_categories(discipline_id, category_id) values(3, 32)') 
      Event.connection.execute('insert into discipline_bar_categories(discipline_id, category_id) values(3, 12)') 
      Event.connection.execute('insert into discipline_bar_categories(discipline_id, category_id) values(3, 31)') 
      Event.connection.execute('insert into discipline_bar_categories(discipline_id, category_id) values(3, 23)') 
    
      downhill = Discipline.find_by_name('Downhill')
      downhill.bar = true
      downhill.save!
    end
  end

  def self.down
  end
end
