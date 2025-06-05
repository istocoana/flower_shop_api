class AddCurrencyToProducts < ActiveRecord::Migration[8.0]
  def change
    add_column :products, :currency, :string
  end
end
