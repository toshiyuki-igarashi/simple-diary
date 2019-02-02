class User < ApplicationRecord
  before_save { self.email.downcase! }
  validates :name, presence: true, length: { maximum: 50 }
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i },
                    uniqueness: { case_sensitive: false }
  has_secure_password

  has_many :diary_forms

  def delete_all
    DiaryForm.where(user_id: self.id).each do |diary_form|
      Diary.where(form_id: diary_form.id).each do |diary|
        diary.delete_images
        diary.destroy
      end
      diary_form.destroy
    end
    self.destroy
  end

  def self.show_all
    self.all.each do |user|
      puts "id:#{user.id}, name:#{user.name}, email:#{user.email}"
    end
    nil
  end
end
