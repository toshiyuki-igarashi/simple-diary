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

  def include_all?(words, value)
    words.each do |word|
      r = Regexp.compile(word)
      return false unless value && r.match?(value)
    end
    true
  end

  def include?(word)
    words = word.gsub(/　/,' ').split(' ')
    values = ''
    include_all?(words, JSON.parse(self[:article]).values.join(''))
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

  def self.prepare_diary(form_id, date)
    diary = Diary.find_by(form_id: form_id, date_of_diary: date)
    if diary == nil
      diary = Diary.new(form_id: form_id, date_of_diary: date)
    else
      diary
    end
  end

  def self.get_diaries(form_id, date, number)
    diaries = []
    0.upto(number) do |i|
      diaries[i] = Diary.prepare_diary(form_id, date - i)
    end
    diaries
  end

  def self.get_diaries_of_years(form_id, date, number)
    diaries = []
    0.upto(number) do |i|
      diaries[i] = Diary.prepare_diary(form_id, Date.commercial(date.cwyear - i, date.cweek, date.cwday))
    end
    diaries
  end

  def self.show_all
    self.all.each do |diary|
      puts "id:#{diary.id}, form_id:#{diary.form_id}, date:#{diary.date_of_diary}, summary:#{diary.get("トピック")}"
    end
    nil
  end
end
