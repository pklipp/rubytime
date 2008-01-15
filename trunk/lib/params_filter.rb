module ParamsFilter

  # Prepares params[:search] to be passed directly to model methods
  def prepare_search_dates
    params[:search]||= {}
    params[:search][:default_month] = session[:month]
    params[:search][:default_year]  = session[:year]
        
    # Fill start date if selected on form
    if params[:dates] and not params[:dates][:date_from].blank?
      params[:search][:date_from] = params[:dates]["date_from(1i)"].to_i.to_s \
          + "-" + params[:dates]["date_from(2i)"].to_i.to_s \
          + "-" + params[:dates]["date_from(3i)"].to_i.to_s
    end
  
    # Fill end date if selected on form
    if params[:dates] and not params[:dates]['date_to(1i)'].blank?
      params[:search][:date_to] = params[:dates]["date_to(1i)"].to_i.to_s \
                + "-" + params[:dates]["date_to(2i)"].to_i.to_s \
                + "-" + params[:dates]["date_to(3i)"].to_i.to_s          
    end
  end
  private :prepare_search_dates
  
  
end