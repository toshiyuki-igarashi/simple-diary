# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
require 'json'
include Math

User.create!(
  id: 1,
  name: 'taro',
  email: 'taro@test.com',
  password_digest: "#{BCrypt::Password.create('taro1234')}",
  created_at: Time.now,
  updated_at: Time.now
)

DIARY_FORM = '{"トピック": {"タイプ": "短文", "単位": ""}, "体重": {"タイプ": "数字", "単位": "kg"}, "本文": {"タイプ": "長文", "単位": ""}}'

DiaryForm.create!(
  id: 1,
  user_id: 1,
  title: '日記帳',
  form: DIARY_FORM,
  created_at: Time.now,
  updated_at: Time.now
)

DiaryForm.create!(
  id: 2,
  user_id: 1,
  title: '標準日記帳',
  form: DiaryForm::DEFAULT_FORM,
  created_at: Time.now,
  updated_at: Time.now
)

# weight fluctuats between +/- 500g
def weight_fluctuation(weight)
  (weight + (rand - 0.5)).round(2)
end

# weight fluctuates up and down
DAYS_NUM = 360
WEIGHT_MAX = 3.0
def weight_of_day(day, weight)
  weight_fluctuation(weight + sin(PI * 2.0 * (day.to_f / DAYS_NUM.to_f)) * WEIGHT_MAX)
end

1.upto(DAYS_NUM) do |i|
  Diary.create!(
    id: i,
    article: JSON.generate({'トピック' => '今日のトピックス', '体重' => "#{weight_of_day(i, 53)}", '本文' => '今日は。。。'}).to_s,
    date_of_diary: Date.today - i,
    created_at: Time.now,
    updated_at: Time.now,
    form_id: 1
  )
end

