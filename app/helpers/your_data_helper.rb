module YourDataHelper

  def activity_calendar(year, month, options = {})
    activities_by_date = @activities.group_by(&:date)

    calendar :year => year.to_i, :month => month.to_i, :first_day_of_week => 1, :table_class => "calendarView" do |date|
      cell_text = content_tag :div, date.mday, :class => 'day-inside'

      if list = activities_by_date[date]
        for act in list
          cell_text << content_tag(:b, hour_format(act.minutes)) << " " << truncate(h(act.project.name), 20)
          cell_text << link_to(' &raquo;', {:action => 'show_activity', :id => act}, :class => 'item-more') << tag(:br)
        end
        cell_text << tag(:br) << content_tag(:i, "total: ") << content_tag(:b, hour_format(list.sum(&:minutes)))
        cell_attrs = {:class => 'day'}
      else
        cell_text << link_to("+", :controller => 'your_data', :action => 'new_activity', :date => date) if params[:controller] != "clientsportal"
        cell_attrs = {:class => 'empty-day'}
      end

      [cell_text, cell_attrs]
    end
  end

end
