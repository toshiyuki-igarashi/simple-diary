class DiaryFormsController < ApplicationController
  before_action :require_user_logged_in

  def edit
  end

  def update
    if (params[:commit] == "項目の追加")
      current_form[""] = { "文字数": "", "単位": "" }
      current_diary_form.update(form: make_form(current_form))
      redirect_to edit_diary_form_url(current_diary_form)
    else
      current_diary_form.update(form: make_form(construct_form(params)))
      redirect_to user_url(current_user)
    end
  end

  private

  def save_item(items, key, item_name, value)
        items[item_name] = {} if items[item_name] == nil
        items[item_name][key] = value
  end

  def construct_form(params)
    items = {}
    params.each do |key, value|
      if (key[0..2] == "項目名")
        save_item(items, "項目名", key[3..-1], value)
      elsif (key[0..2] == "文字数")
        save_item(items, "文字数", key[3..-1], value)
      elsif (key[0..1] == "単位")
        save_item(items, "単位", key[2..-1], value)
      end
    end

    form = {}
    items.each do |key, value|
      form[value["項目名"]] = {}
      form[value["項目名"]] = {"文字数": value["文字数"], "単位": value["単位"]}
    end
    form
  end

  def make_form(form)
    JSON.generate(form)
  end
end
