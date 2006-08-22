class DataUpdate < ActiveRecord::Migration
  def self.up
    execute "UPDATE `projects` SET `id` = 1, `name` = 'First Project', `description` = 'First project', `client_id` = 1, `is_inactive` = 0 WHERE  `id` = 1"
    execute "UPDATE `roles` SET `id` = 1, `name` = 'Project Manager', `short_name` = 'PM', `is_admin` = 1 WHERE  `id` = 1"
    execute "UPDATE `roles` SET `id` = 2, `name` = 'Developer', `short_name` = 'DEV', `is_admin` = 0 WHERE  `id` = 2"
    execute "UPDATE `users` SET `id` = 1, `login` = 'admin', `password` = '7be43c1935a3d4ccd904a062a0e8925fb986829f', `salt` = '287560120.570862222928554', `name` = 'admin', `email` = 'admin@llp.pl', `login_key` = 'uwetyoiuytowiug3h9874tyiquerytoi', `role_id` = 1, `is_inactive` = 0 WHERE  `id` = 1"
  end

  def self.down
    execute "UPDATE `users` SET `id` = 1, `login` = 'admin', `password` = 'admin', `salt` = '', `name` = 'admin', `email` = 'admin@llp.pl', `login_key` = 'uwetyoiuytowiug3h9874tyiquerytoi', `role_id` = 1, `is_inactive` = 0 WHERE  `id` = 1"
  end
end
