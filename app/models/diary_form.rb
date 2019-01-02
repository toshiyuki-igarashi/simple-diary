class DiaryForm < ApplicationRecord
  belongs_to :user

  validates :title, length: { maximum: 50 }, presence: true, uniqueness: { scope: :user }

  has_many :diaries

  DEFAULT_FORM = '{"トピック": {"タイプ": "短文", "単位": ""}, "本文": {"タイプ": "長文", "単位": ""}}'

  def get_form
    JSON.parse(form)
  end

  def self.show_all
    self.all.each do |diary_form|
      puts "id:#{diary_form.id}, user_id:#{diary_form.user_id}, title:#{diary_form.title}, form:#{diary_form.form}"
    end
    nil
  end
end
