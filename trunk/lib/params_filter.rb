module ParamsFilter

  # Prepares params[:search] to be passed directly to model methods
  private
  def prepare_search_dates
    params[:search] ||= {}
    params[:search][:default_month] = session[:month]
    params[:search][:default_year]  = session[:year]
  end

end