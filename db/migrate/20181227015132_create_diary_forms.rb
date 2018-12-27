class CreateDiaryForms < ActiveRecord::Migration[5.0]
  def change
    create_table :diary_forms do |t|
      t.integer :user_id
      t.string :title
      t.string :form

      t.timestamps
    end
  end
end
