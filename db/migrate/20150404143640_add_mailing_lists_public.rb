class AddMailingListsPublic < ActiveRecord::Migration
  def change
    add_column :mailing_lists, :public, :boolean, default: true, null: false
  end
end
