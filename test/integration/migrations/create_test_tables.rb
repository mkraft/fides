class CreateTestTables < ActiveRecord::Migration
  def change
    create_table :clothing_articles do |t|
      t.string  :name
      t.integer :wearable_id
      t.string  :wearable_type
      t.timestamps
    end

    create_table :babies do |t|
      t.string :name
      t.timestamps
    end

    create_table :seniors do |t|
      t.string :name
      t.timestamps
    end

    create_table :teenagers do |t|
      t.string :name
      t.timestamps
    end
  end
end