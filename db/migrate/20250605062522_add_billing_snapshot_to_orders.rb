class AddBillingSnapshotToOrders < ActiveRecord::Migration[8.0]
  def change
     add_column :orders, :billing_full_name, :string, null: false
    add_column :orders, :billing_address_line, :string, null: false
    add_column :orders, :billing_city, :string, null: false
    add_column :orders, :billing_zip, :string, null: false
    add_column :orders, :billing_country, :string, null: false
    add_column :orders, :billing_country_code, :string, null: false
    add_column :orders, :billing_phone, :string, null: false
  end
end
