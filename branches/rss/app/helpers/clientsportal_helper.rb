module ClientsportalHelper
  def activities_in_last(n_days)
    link_to_remote "Activities in last #{n_days} days",
      :update => :time_period,
      :url => {:controller => :clientsportal,
        :action => :report_by_role,
        :id => params[:id],
        :from_date => n_days.days.ago.to_date,
        :to_date => Date.today.to_date
      },
      :before => "$('time_period_loader').show();",
      :complete => "$('time_period_loader').hide();"
  end
end
