class AddUpdatedIndexes < ActiveRecord::Migration
  def change
    add_index :articles, :updated_at
    add_index :article_categories, :updated_at
    add_index :categories, :updated_at
    add_index :events, :updated_at
    add_index :homes, :updated_at
    add_index :mailing_lists, :updated_at
    add_index :pages, :updated_at
    add_index :people, :updated_at
    add_index :photos, :updated_at
    add_index :posts, :updated_at
    add_index :races, :updated_at
    add_index :results, :updated_at
    add_index :teams, :updated_at

    add_index :articles, :article_category_id
  end
end
