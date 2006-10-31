ActiveRecord::Schema.define :version => 0 do
  create_table :people, :force => true do |t|
    t.column :first_name,   :string
    t.column :middle_name,  :string
    t.column :last_name,    :string
    t.column :city,         :string
    t.column :country,      :string
    t.column :birthdate,    :date
    t.column :lucky_number, :integer
  end
end
