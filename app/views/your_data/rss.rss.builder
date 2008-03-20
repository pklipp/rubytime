xml.instruct! :xml, :version => '1.0'

xml.rss :version => '2.0' do
  xml.channel do

    xml.title "RubyTime RSS feed"
    xml.link url_for(:controller => 'login', :only_path => false)
    xml.description "RubyTime RSS feed"
    xml.language 'en'

    @days.sort.reverse.each do |day, day_projects|
      xml.item do
        xml.title "Day #{day}"
        xml.pubDate @pub_dates[day].rfc822
        xml.guid day

        text = ""

        day_projects.sort_by {|k, v| k.name}.each do |project, project_roles|
          text << "<h4>Project #{project.name}</h4>\n"
          text << "<ul>\n"
          project_roles.sort_by {|k, v| k.name}.each do |role, role_users|
            text << "<li>#{role.name.pluralize} (#{hour_format(role_users.keys.sum {|u| role_users[u][0].minutes})})\n"
            text << "<ul>\n"
            role_users.sort_by {|k, v| k.name}.each do |user, activities|
              text << "<li>#{user.name} &minus; #{hour_format(activities[0].minutes)}"
              text << " (#{activities[0].date})" if activities[0].created_at.to_date != activities[0].date
              text << "</li>\n"
            end
            text << "</ul></li>\n"
          end
          text << "</ul>\n"
        end

        xml.description text

      end
    end
  end
end
