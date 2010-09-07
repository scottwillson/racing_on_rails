p `mysqldump -u root aba_development > db/aba.sql`

open("export.sql", "w") { |sql|
  sql << "SET foreign_key_checks = 0;\n"
    {
      "aliases"       => [ "id", "person_id", "team_id" ],
      "categories"        => [ "id", "parent_id" ],
      "categories_offers" => [ "category_id", "offer_id" ],
      "click_counts"      => [ "id", "offer_id" ],
      "email_recipients"  => [ "id" ],
      "impression_counts" => [ "id", "offer_id" ],
      "leads"             => [ "id", "offer_id" ],
      "mobile_phones"     => [ "id" ],
      "offer_changes"     => [ "id", "offer_id", "publisher_id" ],
      "offers"            => [ "id", "advertiser_id" ],
      "publishers"        => [ "id", "publishing_group_id" ],
      "publishing_groups" => [ "id" ],
      "stores"            => [ "id", "advertiser_id" ],
      "txts"              => [ "id", "source_id" ],
      "users"             => [ "id", "company_id" ],
      "visitors"          => [ "id" ]
    }.each do |table, columns|
      columns.each do |column|
        sql << "SET foreign_key_checks = 0;\n"
        sql << "update #{table} set #{column} = #{column} + 400000;\n"
        sql << "SET foreign_key_checks = 1;\n"
      end
    end
  }
end
