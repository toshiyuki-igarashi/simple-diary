module DiaryFormsHelper
  def download_file_name
    @download_file ||= session[session_sym(:download_file)]
  end

  def download_file_exist?
    session[session_sym(:download_file)] != nil
  end
end
