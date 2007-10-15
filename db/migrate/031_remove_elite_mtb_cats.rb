class RemoveEliteMtbCats < ActiveRecord::Migration
  def self.up
    cat = Category.find_by_name('Pro, Semi-Pro, Elite Men')
    cat.name = 'Pro, Semi-Pro Men'
    cat.save!
    
    cat = Category.find_by_name('Pro, Elite, Expert Women')
    cat.name = 'Pro, Expert Women'
    cat.save!
  end

  def self.down
  end
end
