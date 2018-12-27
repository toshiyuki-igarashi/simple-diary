class DiaryForm < ApplicationRecord
  belongs_to :user

  validates :title, length: { maximum: 50 }
  has_many :diaries

  def self.show_all
    self.all.each do |diary_form|
      puts "id:#{diary_form.id}, user_id:#{diary_form.user_id}, title:#{diary_form.title}, form:#{diary_form.form}"
    end
    nil
  end

  def self.initialize_forms
    self.all.each do |diary_form|
      if (diary_form.update(form: '{"トピック": 50,"本文": 0}'))
        puts "成功：#{diary_form.id}"
      else
        puts "失敗：#{diary_form.id}"
      end
    end
  end
end
