class CreateLanguages < ActiveRecord::Migration[8.0]
  def change
    create_table :languages do |t|
      t.string :code, null: false
      t.string :name, null: false
      t.boolean :is_learnable, null: false, default: false
    end

    add_index :languages, :code, unique: true
  end
end
