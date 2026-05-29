class CreateCompanions < ActiveRecord::Migration[8.0]
  def change
    create_table :companions do |t|
      t.references :language, null: false, foreign_key: true, index: { unique: true }
      t.string :name, null: false
      t.string :species, null: false
      t.text :persona, null: false
    end
  end
end
