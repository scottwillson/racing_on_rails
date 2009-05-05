class StandardizeSchemas < ActiveRecord::Migration
  def self.up
    drop_table :comatose_page_versions rescue nil
    drop_table :comatose_pages rescue nil
    drop_table :engine_schema_info rescue nil
    drop_table :images rescue nil
    drop_table :news_items rescue nil

    change_table :bids do |t|
      t.change_default(:name, nil)
      t.change_default(:email, nil)
      t.change_default(:phone, nil)
      t.change_default(:amount, nil)
    end
    
    change_table :categories do |t|
      t.change_default :friendly_param, nil
    end

    change_table :import_files do |t|
      t.change_default :name, nil
    end

    change_table :races do |t|
      t.change_default :sanctioned_by, nil
    end
    
    execute "alter table competition_event_memberships default charset=utf8"
  end

  def self.down
    change_table :categories do |t|
      t.change_default :friendly_param, ""
    end

    change_table :bids do |t|
      t.change_default(:name, "")
      t.change_default(:email, "")
      t.change_default(:phone, "nil")
      t.change_default(:amount, 0)
    end

    change_table :import_files do |t|
      t.change_default :name, ""
    end

    change_table :races do |t|
      t.change_default :sanctioned_by, ASSOCIATION.short_name
    end
  end
end
