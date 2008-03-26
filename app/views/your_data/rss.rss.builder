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
        xml.guid day, :isPermaLink => false

        text = ""
        day_projects.sort_by {|k, v| k.name}.each do |project, project_roles|
          text << render(:partial => 'project_in_rss', :object => project, :locals => {:roles => project_roles, :project_tag => '<h4>'})
        end
        xml.description text
      end
    end
  end
end
