# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
require 'json'

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

Diary.create!(
  id: 1,
  article: JSON.generate({'トピック' => '今日のトピックス', '体重' => '53', '本文' => '今日は。。。'}).to_s,
  date_of_diary: Date.today,
  created_at: Time.now,
  updated_at: Time.now,
  form_id: 1
)

