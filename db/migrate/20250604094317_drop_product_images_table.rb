class DropProductImagesTable < ActiveRecord::Migration[8.0]
  def up
    drop_table :product_images
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
