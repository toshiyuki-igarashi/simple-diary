class RemoveSummaryFromDiaries < ActiveRecord::Migration[5.0]
  def change
    remove_column :diaries, :summary, :string
  end
end
