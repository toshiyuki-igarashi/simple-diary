class CreateDiaries < ActiveRecord::Migration[5.0]
  def change
    create_table :diaries do |t|
      t.integer :user_id
      t.string :summary
      t.text :article
      t.date :date_of_diary

      t.timestamps
    end
  end
end
