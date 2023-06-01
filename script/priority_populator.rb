ENV['RAILS_ENV'] = 'staging'
require '/var/www/rails/links_engine/current/config/environment.rb'
title = 0

until title == -1
  puts "Enter Title:"
  title = gets.chomp
  
  if title == -1
    return
  end
  
  li = Priority.create(
      :title => title,
      :description => "",
      :priority => Priority.get_lowest_priority + 1,
      :status => "New",
      :author => "bhill",
      :assignee => "JTP"
  )
end 
