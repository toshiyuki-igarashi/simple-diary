module DiaryFormsHelper
  def download_file_name
    @download_file ||= session[:download_file]
  end

  def download_file_exist?
    session[:download_file] != nil
  end
end
