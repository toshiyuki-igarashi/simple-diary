module DiariesHelper
  def search
    if (params[:commit] == "検索") && logged_in?
      session[:search_keyword] = params[:search]
      redirect_to show_search_url
    else
      session[:search_keyword] = ''
    end
  end
end
