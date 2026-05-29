class CreateThemes < ActiveRecord::Migration[8.0]
  def change
    create_table :themes do |t|
      t.references :language, null: false, foreign_key: true
      t.string :name, null: false
      t.integer :display_order, null: false, default: 0
    end

    add_index :themes, [:language_id, :name], unique: true
  end
end
