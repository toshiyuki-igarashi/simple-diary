class Diary < ApplicationRecord
  belongs_to :user
  belongs_to :diary_form, :foreign_key => 'form_id'

  validates :summary, length: { maximum: 50 }
  validates :date_of_diary, presence: true, uniqueness: { scope: :user }

  def self.search_diary(search_keyword, user)
    diaries_all = Diary.where(user_id: user.id)
    diaries = []
    diaries_all.each do |diary|
      if (diary[:summary] && diary[:summary].include?(search_keyword)) || (diary[:article] && diary[:article].include?(search_keyword))
        diaries.push(diary)
      end
    end
    diaries.sort! { |a , b|
      if a[:date_of_diary] < b[:date_of_diary]
        1
      elsif a[:date_of_diary] == b[:date_of_diary]
        0
      else
        -1
      end
    }
  end

  def self.show_all
    self.all.each do |diary|
      puts "id:#{diary.id}, user_id:#{diary.user_id}, form_id:#{diary.form_id}, date:#{diary.date_of_diary}, summary:#{diary.summary}"
    end
    nil
  end

  def self.initialize_form_id
    User.all.each do |user|
      form_id = DiaryForm.find_by(user_id: user.id).id
      Diary.where(user_id: user.id).each do |diary|
        if (diary.update(form_id: form_id))
          puts "成功：#{diary.id}"
        else
          puts "失敗：#{diary.id}"
        end
      end
    end
  end
end
