# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* Database structure
users
  "id" integer PRIMARY KEY AUTOINCREMENT NOT NULL
  "name" varchar
  "email" varchar
  "password_digest" varchar
  "created_at" datetime NOT NULL
  "updated_at" datetime NOT NULL

diaries
  "id" integer NOT NULL PRIMARY KEY
  "article" text DEFAULT NULL
  "date_of_diary" date DEFAULT NULL
  "created_at" datetime NOT NULL
  "updated_at" datetime NOT NULL
  "form_id" integer DEFAULT NULL

diary_forms
  "id" integer PRIMARY KEY AUTOINCREMENT NOT NULL
  "user_id" integer
  "title" varchar
  "form" varchar
  "created_at" datetime NOT NULL
  "updated_at" datetime NOT NULL

