class RemoveEliteMtbCats < ActiveRecord::Migration
  def self.up
    cat = Category.find_by_name('Pro, Semi-Pro, Elite Men')
    if cat
      cat.name = 'Pro, Semi-Pro Men'
      cat.save!
    end
    
    cat = Category.find_by_name('Pro, Elite, Expert Women')
    if cat
      cat.name = 'Pro, Expert Women'
      cat.save!
    end
  end

  def self.down
  end
end
