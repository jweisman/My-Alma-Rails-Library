class CreateFilestreams < ActiveRecord::Migration
  def change
    create_table :filestreams do |t|
      t.string :file_name
      t.string :file_content_type
      t.integer :file_size
      t.string :url
      t.string :key
      t.string :bucket
      t.belongs_to :deposit

      t.timestamps
    end
  end
end
