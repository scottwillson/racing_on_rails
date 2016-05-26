class RenameDupeIndex < ActiveRecord::Migration
  def change
    remove_foreign_key :categories, name: :categories_categories_id_fk
    remove_foreign_key :discipline_aliases, name: :discipline_aliases_disciplines_id_fk
    remove_foreign_key :discipline_bar_categories, name: :discipline_bar_categories_disciplines_id_fk
    remove_foreign_key :events, name: :events_events_id_fk
    remove_foreign_key :people, name: :people_team_id_fk
    remove_foreign_key :races, name: :races_category_id_fk
    remove_foreign_key :results, name: :results_category_id_fk
    remove_foreign_key :results, name: :results_team_id_fk
    remove_index :categories, name: :parent_id
    remove_index :discipline_aliases, name: :idx_discipline_id
    remove_index :discipline_bar_categories, name: :idx_category_id
    remove_index :discipline_bar_categories, name: :idx_discipline_id
    remove_index :events, name: :idx_date
    remove_index :events, name: :parent_id
    remove_index :mailing_lists, name: :idx_name
    remove_index :people, name: :idx_team_id
    remove_index :posts, name: :idx_date
    remove_index :races, name: :idx_category_id
    remove_index :results, name: :idx_category_id
    remove_index :results, name: :idx_team_id
    remove_index :teams, name: :idx_name

    add_index :categories, :parent_id
    add_index :discipline_aliases, :discipline_id
    add_index :discipline_bar_categories, :discipline_id
    add_index :events, :date
    add_index :events, :parent_id
    add_index :mailing_lists, :name
    add_index :people, :team_id
    add_index :posts, :date
    add_index :races, :category_id
    add_index :results, :category_id
    add_index :results, :team_id
    add_index :teams, :name
    add_foreign_key :categories, :categories, column: "parent_id", on_delete: :cascade
    add_foreign_key :discipline_aliases, :disciplines, on_delete: :cascade
    add_foreign_key :discipline_bar_categories, :disciplines, on_delete: :cascade
    add_foreign_key :events, :events, column: "parent_id", on_delete: :cascade
    add_foreign_key :people, :teams
    add_foreign_key :races, :categories
    add_foreign_key :results, :categories
    add_foreign_key :results, :teams
  end
end
