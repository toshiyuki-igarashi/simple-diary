class DiaryFormsController < ApplicationController
  before_action :require_user_logged_in
  before_action :search

  def edit
  end

  def update
    selected = []
    items = construct_form(params, selected)
    go_to_url = edit_diary_form_url(current_diary_form)

    case (params[:commit])
    when "保存"
      form = items
      go_to_url = user_url(current_user)
    when "追加"
      form = insert_item(items, selected)
    when "上"
      form = move_up_item(items, selected)
    when "下"
      form = move_down_item(items, selected)
    when "削除"
      form = delete_item(items, selected)
    else
      form = items
    end

    current_diary_form.update(form: make_form(form))
    redirect_to go_to_url
  end

  private

  def save_item(items, key, item_name, value)
        items[item_name] = {} if items[item_name] == nil
        items[item_name][key] = value
  end

  def construct_form(params, selected)
    items = {}
    params.each do |key, value|
      if (key[0..2] == "項目名")
        save_item(items, "項目名", key[3..-1], value)
      elsif (key[0..2] == "タイプ")
        save_item(items, "タイプ", key[3..-1], value)
      elsif (key[0..1] == "単位")
        save_item(items, "単位", key[2..-1], value)
      end

      if (value == 'select')
        selected.push(key)
      end
    end

    form = {}
    items.each do |key, value|
      form[value["項目名"]] = {}
      form[value["項目名"]] = {"タイプ": value["タイプ"], "単位": value["単位"]}
    end
    form
  end

  def insert_item(items, selected)
    form = {}
    items.each do |key, value|
      if selected.include?(key)
        form[""] = { "タイプ": "", "単位": "" }
      end
      form[key] = value
    end

    if (selected.size == 0)
      form[""] = { "タイプ": "", "単位": "" }
    end
    form
  end

  def copy_value(keys, original, target)
    (0..keys.length-1).each do |i|
      target[keys[i]] = original[keys[i]]
    end
    target
  end

  def move_up_item(items, selected)
    form = {}
    keys = items.keys
    if (keys.length >= 2)
      1.upto(keys.length-1) do |i|
        if selected.include?(keys[i])
          temp = keys[i-1]
          keys[i-1] = keys[i]
          keys[i] = temp
        end
      end
    end

    copy_value(keys, items, form)
  end

  def move_down_item(items, selected)
    form = {}
    keys = items.keys
    if (keys.length >= 2)
      (keys.length-1).downto(1) do |i|
        if selected.include?(keys[i-1])
          temp = keys[i-1]
          keys[i-1] = keys[i]
          keys[i] = temp
        end
      end
    end

    copy_value(keys, items, form)
  end

  def delete_item(items, selected)
    form = {}
    items.each do |key, value|
      if !selected.include?(key)
        form[key] = value
      end
    end
    form
  end

  def make_form(form)
    JSON.generate(form)
  end
end
