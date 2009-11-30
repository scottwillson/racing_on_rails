class ChangePrintMailingLabelToCardPrintedOn < ActiveRecord::Migration
  def self.up
    change_table :people do |t|
      t.remove :print_mailing_label
      t.datetime :card_printed_at
    end
  end

  def self.down
    change_table :people do |t|
      t.boolean :print_mailing_label
      t.remove :card_printed_at
    end
  end
end
