class RemoveUserIdFromDiaries < ActiveRecord::Migration[5.0]
  def change
    remove_column :diaries, :user_id, :integer
  end
end
