class AddFormIdToDiaries < ActiveRecord::Migration[5.0]
  def change
    add_column :diaries, :form_id, :integer
  end
end
