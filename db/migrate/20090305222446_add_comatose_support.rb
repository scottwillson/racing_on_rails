class ComatosePage < ActiveRecord::Base
  set_table_name 'comatose_pages'
  acts_as_versioned :table_name=>'comatose_page_versions', :if_changed => [:title, :slug, :keywords, :body]
end


class AddComatoseSupport < ActiveRecord::Migration

  # Schema for Comatose version 0.7+
  def self.up
    create_table :comatose_pages do |t|
      t.integer   "parent_id"
      t.text      "full_path",   :default => ''
      t.string    "title",       :limit => 255
      t.string    "slug",        :limit => 255
      t.string    "keywords",    :limit => 255
      t.text      "body"
      t.string    "filter_type", :limit => 25
      t.string    "author",      :limit => 255
      t.integer   "position",    :default => 0
      t.integer   "version"
      t.datetime  "updated_on"
      t.datetime  "created_on"
    end
    ComatosePage.create_versioned_table
    puts "Creating the default 'Home Page'..."
    ComatosePage.create( :title=>'Home Page', :body=>"Welcome\n\nThis is the top page in the /static directory.", :author => 'System' )
  end

  def self.down
    ComatosePage.drop_versioned_table
    drop_table :comatose_pages
  end

end
