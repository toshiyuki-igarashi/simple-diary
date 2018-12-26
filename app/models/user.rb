class User < ApplicationRecord
  before_save { self.email.downcase! }
  validates :name, presence: true, length: { maximum: 50 }
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i },
                    uniqueness: { case_sensitive: false }
  has_secure_password

  has_many :diaries

  def self.show_all
    self.all.each do |user|
      puts "id:#{user.id}, name:#{user.name}, email:#{user.email}"
    end
  end

  def delete_all
    Diary.where(user_id: self.id).each do |diary|
      diary.destroy
    end
    self.destroy
  end
end
