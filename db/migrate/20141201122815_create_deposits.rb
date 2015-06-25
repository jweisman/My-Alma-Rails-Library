class CreateDeposits < ActiveRecord::Migration
  def change
    create_table :deposits do |t|
      t.integer :import_profile, limit: 8, null: false 
      t.text :metadata
      t.string :folder_name
      t.string :bucket
      t.string :status
      t.belongs_to :user
      t.timestamps
    end
  end
end
