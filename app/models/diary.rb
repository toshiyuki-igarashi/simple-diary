class Diary < ApplicationRecord
  belongs_to :diary_form, :foreign_key => 'form_id'

  validates :date_of_diary, presence: true, uniqueness: { scope: :diary_form }

  def get_user_id
    DiaryForm.find(self.form_id).user_id
  end

  def get(term)
    if term && self[:article]
      JSON.parse(self[:article])[term]
    else
      nil
    end
  end

  def include?(word)
    JSON.parse(self[:article]).each do |key, value|
      return true if value && value.include?(word)
    end
    false
  end

  def self.search_diary(search_keyword, form_id)
    diaries_all = Diary.where(form_id: form_id)
    diaries = []
    diaries_all.each do |diary|
      if (diary.include?(search_keyword))
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
      puts "id:#{diary.id}, form_id:#{diary.form_id}, date:#{diary.date_of_diary}, summary:#{diary.get("トピック")}"
    end
    nil
  end
end
