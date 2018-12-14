class Diary < ApplicationRecord
  belongs_to :user

  validates :summary, length: { maximum: 50 }
  validates :date_of_diary, presence: true, uniqueness: { scope: :user_id }
end
