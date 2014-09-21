class EnsurePostTextsIsam < ActiveRecord::Migration
  def change
    if PostText.count == 0
      create_table "post_texts", force: true, options: "ENGINE=MyISAM" do |t|
        t.integer  "post_id",    null: false
        t.text     "text"
        t.datetime "created_at"
        t.datetime "updated_at"
      end

      add_index "post_texts", ["post_id"], name: "index_post_texts_on_post_id", using: :btree
      add_index "post_texts", ["text"], name: "post_text", type: :fulltext
    end
  end
end
