ENV['RAILS_ENV'] = 'staging'
require '/var/www/rails/links_engine/current/config/environment.rb'
title = 0

Priority.where(:status => "Pushed").each do |priority|
  Priority.move_to_completed(priority)
end
