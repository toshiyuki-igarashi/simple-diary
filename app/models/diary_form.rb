class DiaryForm < ApplicationRecord
  belongs_to :user

  validates :title, length: { maximum: 50 }, presence: true, uniqueness: { scope: :user }

  has_many :diaries

  DEFAULT_FORM = '{"トピック": {"文字数": 50, "単位": ""}, "本文": {"文字数": 0, "単位": ""}}'
  SIZE_OF_AREA = 0

  def get_form
    JSON.parse(form)
  end

  def self.show_all
    self.all.each do |diary_form|
      puts "id:#{diary_form.id}, user_id:#{diary_form.user_id}, title:#{diary_form.title}, form:#{diary_form.form}"
    end
    nil
  end

  def self.initialize_forms
    self.all.each do |diary_form|
      if (diary_form.update(form: DEFAULT_FORM))
        puts "成功：#{diary_form.id}"
      else
        puts "失敗：#{diary_form.id}"
      end
    end
  end
end
