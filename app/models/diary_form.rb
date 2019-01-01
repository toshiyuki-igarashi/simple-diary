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

  def self.initialize_forms
    self.all.each do |diary_form|
      form = JSON.parse(diary_form[:form])
      form.each do |key, value|
        if (key == "トピック")
          value["タイプ"] = "短文"
        elsif (key == "本文")
          value["タイプ"] = "長文"
        else
          value["タイプ"] = "数字"
        end
        value.delete("文字数")
      end
      if (diary_form.update(form: JSON.generate(form)))
        puts "成功：#{diary_form.id}"
      else
        puts "失敗：#{diary_form.id}"
      end
    end
  end
end
