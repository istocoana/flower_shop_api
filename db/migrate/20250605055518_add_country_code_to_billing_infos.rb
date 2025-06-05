class AddCountryCodeToBillingInfos < ActiveRecord::Migration[8.0]
  def change
    add_column :billing_infos, :country_code, :string, null: false
  end
end
