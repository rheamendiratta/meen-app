class CreateFsrsCards < ActiveRecord::Migration[8.0]
  def change
    create_table :fsrs_cards do |t|
      t.references :user, null: false, foreign_key: true
      t.references :word, null: false, foreign_key: true
      t.string :card_type, null: false
      t.float :stability
      t.float :difficulty
      t.string :state, null: false, default: "new"
      t.integer :reps, null: false, default: 0
      t.integer :lapses, null: false, default: 0
      t.integer :scheduled_days, null: false, default: 0
      t.datetime :due_at
      t.datetime :last_reviewed_at
    end

    add_index :fsrs_cards, [:user_id, :word_id, :card_type], unique: true
    add_index :fsrs_cards, :due_at
    add_check_constraint :fsrs_cards,
      "card_type IN ('recognition', 'production')",
      name: "chk_fsrs_cards_card_type"
    add_check_constraint :fsrs_cards,
      "state IN ('new', 'learning', 'review', 'relearning')",
      name: "chk_fsrs_cards_state"
  end
end
