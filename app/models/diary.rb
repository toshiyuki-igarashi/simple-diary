class Diary < ApplicationRecord
  belongs_to :user

  validates :summary, length: { maximum: 50 }
end
