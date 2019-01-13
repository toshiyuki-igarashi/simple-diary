module DiariesHelper
  def search
    if (params[:commit] == "検索") && logged_in?
      session[:search_keyword] = params[:search]
      redirect_to show_day_url(view_mode: 'show_search')
    end
  end

  def is_valid_number?(s)
    !(s == nil || /[0-9\.]+/ !~ s)
  end

  def get_real_max(data)
    @max_values = []
    0.upto(data.length-1) do |i|
      @max_values[i] = data[i][:data].values.map(&:to_f).each.max
    end
    @max_values.each.max
  end

  def significant_digits(data)
    max_value = get_real_max(data)
    if max_value == 0
      2
    else
      2-Math::log10(max_value).ceil
    end
  end

  def get_max(data)
    get_real_max(data).ceil(significant_digits(data))
  end

  def get_min(data)
    @min_values = []
    0.upto(data.length-1) do |i|
      min_data = []
      0.upto(data[i][:data].values.length-1) do |j|
        min_data.push(data[i][:data].values[j]) if is_valid_number?(data[i][:data].values[j])
      end
      if min_data.length > 0
        @min_values[i] = min_data.map(&:to_f).each.min
      else
        @min_values[i] = 0
      end
    end
    @min_values.each.min.floor(significant_digits(data))
  end
end
