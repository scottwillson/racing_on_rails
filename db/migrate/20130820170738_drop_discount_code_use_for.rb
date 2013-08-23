class DropDiscountCodeUseFor < ActiveRecord::Migration
  def change
    begin
      remove_column :discount_codes, :use_for
    rescue Exception => e
      # OK, not all associations have this table
    end
  end
end
