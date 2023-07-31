require 'zip'
require 'kconv'

class DiaryFormsController < ApplicationController
  before_action :require_user_logged_in
  before_action :search

  def edit
  end

  def new
    form_idx = user_diary_forms.size
    if (!DiaryForm.new(user_id: current_user.id, title: "日記帳(#{form_idx})", form: DiaryForm::DEFAULT_FORM).save)
      puts "**** Alert **** diary_form hasn't saved for user (user_id: #{@user.id}) [CODE 100]"
      flash[:success] = 'プログラムエラーで新規日記に失敗しました。[CODE 200]'
    else
      session[:form_idx] = form_idx
    end
  end

  def update
    selected = []
    diary_title = params['日記名']
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

    current_diary_form.update(title: diary_title, form: make_form(form))
    redirect_to go_to_url
  end

  def download
  end

  def download_file
    if (params[:commit] == 'ファイルの作成')
      pass = params[:pass][0]
      if (pass == nil || pass.delete(' ') == '')
        flash[:danger] = 'パスワードが入力されていないので、日記のファイル生成に失敗しました'
      else
        session[:download_file] = make_download_file_name + '.zip'
        compress_string(make_diary_data, make_download_file_name + '.json', "#{Rails.root.to_s}/public/data/#{download_file_name}", pass)
        flash[:success] = '日記のファイルが正常に生成されました'
      end
    else
      download_file_clear
    end
    redirect_to download_url
  end

  def upload
  end

  def upload_file
    pass = params[:pass][0]
    file = params['upload']

    name = file.original_filename
    name = name.kconv(Kconv::UTF8, Kconv::AUTO)
    File.open("#{Rails.root.to_s}/public/data/#{name}", 'wb') { |f| f.write(file.read) }
    if File.extname(name).downcase == '.zip'
      diary_file_name = uncompress("#{Rails.root.to_s}/public/data", "#{Rails.root.to_s}/public/data/#{name}", pass)
      system("rm #{Rails.root.to_s}/public/data/#{name}")
    else
      diary_file_name = "#{Rails.root.to_s}/public/data/#{name}"
    end

    if diary_file_name && diary_file_name.delete(' ') != ''
      load_diary(diary_file_name)
      system("rm #{diary_file_name}")
      flash[:success] = '日記が正常にアップロードされました'
    else
      flash[:danger] = 'パスワードエラーまたは他の理由で日記のアップロードに失敗しました'
    end

    redirect_to user_url(current_user)
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

  def make_download_file_name
    User.find(current_user.id).email.gsub('@','.') + "_" + DiaryForm.find(current_form_id).title
  end

  def get_all_diary
    diaries = '{'
    Diary.where(form_id: current_form_id).each do |diary|
      diaries += '"' + diary[:date_of_diary].to_s + '": ' + diary[:article] + ', '
    end
    diaries += '"end": ""}'
  end

  def make_diary_data
    '{"Title": "' + current_diary_form.title +
      '", "Form": ' + current_diary_form.form +
      ', "Diary": ' + get_all_diary + '}'
  end

  def load_diary_form(title, form)
#     target = DiaryForm.find_by(user_id: current_user.id, title: title)  # 複数の日記を取り扱う際に使う
    target = DiaryForm.find_by(user_id: current_user.id)  # 単数の日記を扱う場合の記述
    if target
#       target.update(form: JSON.generate(form))  # 複数の日記を取り扱う際に使う
      target.update(title: title, form: JSON.generate(form))  # 単数の日記を扱う場合の記述
    else
      DiaryForm.new(user_id: current_user.id, title: title, form: DiaryForm::DEFAULT_FORM).save
      target = DiaryForm.find_by(user_id: current_user.id, title: title)
    end
    target
  end

  def load_one_diary(date, diary)
    target = Diary.find_by(form_id: current_form_id, date_of_diary: date)
    if target
      target.update(article: JSON.generate(diary))
    else
      Diary.new(form_id: current_form_id, date_of_diary: date, article: JSON.generate(diary)).save
    end
  end

  def load_diaries(diaries)
    diaries.each do |date, diary|
      load_one_diary(date,  diary) unless date == "end"
    end
  end

  def load_diary(diary_file_name)
    File.open(diary_file_name) do |file|
      @diary = file.read
    end
    @diary_data = JSON.parse(@diary)
    @title = @diary_data["Title"]
    @form = @diary_data["Form"]
    @diaries = @diary_data["Diary"]

#     change_diary_form(load_diary_form(@title, @form)) # 複数の日記を取り扱う際に使う
    load_diary_form(@title, @form)  # 単数の日記を扱う場合の記述
    load_diaries(@diaries)
  end

  def compress_string(string, filename, zippath, password)
    # パスワードのオブジェクト作る
    encrypter = password.present? ? Zip::TraditionalEncrypter.new(password) : nil

    buffer = Zip::OutputStream.write_buffer(::StringIO.new(''), encrypter) do |out|
      out.put_next_entry(filename)
      file_buf = StringIO.open(string, &:read)
      out.write file_buf
    end
    # Stream書き出す
    f = File.open(zippath, 'wb')
    f.write(buffer.string)
    f.close
    zippath
  end

  def uncompress(path, zippath, password)
    # zipパスワードを作成
    encrypter = password.present? ? Zip::TraditionalDecrypter.new(password) : nil

    begin
      # 第3引数にパスワードを指定、第2引数は0固定
      Zip::InputStream.open(zippath, 0, encrypter) do |input|
        entry = input.get_next_entry
        if (entry)
          file_name = path + '/' + entry.name
          Dir.mkdir(File.dirname(file_name)) unless Dir.exist?(File.dirname(file_name))
          File.binwrite(file_name, input.read)
        end
        file_name
      end
    rescue Zlib::DataError
      # password error発生時
      nil
    end
  end

end
