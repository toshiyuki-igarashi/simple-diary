class DiaryForm < ApplicationRecord
  belongs_to :user

  validates :title, length: { maximum: 50 }
  has_many :diaries

  def self.initialize_forms
    User.all.each do |user|
      diary_form = DiaryForm.new(user_id: user.id, title: '日記帳', form: 'トピック,本文')
      if (diary_form.save)
        puts '成功：#{user.id}'
      else
        puts '失敗：#{user.id}'
      end
    end
  end

  def self.show_all
    self.all.each do |diary_form|
      puts "id:#{diary_form.id}, user_id:#{diary_form.user_id}, title:#{diary_form.title}, form:#{diary_form.form}"
    end
    nil
  end
end
