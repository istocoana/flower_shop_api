class CreateBillingInfos < ActiveRecord::Migration[8.0]
  def change
    create_table :billing_infos do |t|
      t.references :user, null: false, foreign_key: true
      t.string :full_name, null: false
      t.string :phone, null: false
      t.string :address_line, null: false
      t.string :city, null: false
      t.string :zip, null: false
      t.string :country, null: false

      t.timestamps
    end
  end
end
