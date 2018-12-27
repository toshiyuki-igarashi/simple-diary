class Diary < ApplicationRecord
  belongs_to :user
#  belongs_to :diary_form

  validates :summary, length: { maximum: 50 }
  validates :date_of_diary, presence: true, uniqueness: { scope: :user_id }

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
      puts "id:#{diary.id}, user_id:#{diary.user_id}, date:#{diary.date_of_diary}, summary:#{diary.summary}"
    end
    nil
  end
end
