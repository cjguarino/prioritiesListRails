class Priority < ActiveRecord::Base

  self.table_name = :priority
  self.primary_key = :id
  has_many :comments, class_name: 'PrioritiesComments'

  def Priority.get_status_array
    return ["New","Development","Pushed","Need More Info","Cannot Complete"]
  end

  def Priority.get_assignee_array
    return ["JTP","cguarino"]
  end

  def Priority.get_data(chosen_status, chosen_assignee)
    begin
      if chosen_status == "Status(All)"
        chosen_assignee == "Assignee(All)" ? list = Priority.all : list = Priority.where(:assignee => chosen_assignee)
      else
        chosen_assignee == "Assignee(All)" ? list = Priority.where(:status => chosen_status) : list = Priority.where(:assignee => chosen_assignee, :status => chosen_status)
      end
    rescue
      list = Priority.all
    end
    return list.sort_by{|x| x.priority}
  end

  def Priority.get_all_data
    return Priority.all.sort_by{|x| x.priority}
  end

  def Priority.get_all_used_priorities
    return Priority.get_all_data.map{|x| x.priority}
  end

  def Priority.get_lowest_priority
    array = Priority.get_all_used_priorities
    return array[array.size - 1].to_i == nil ? 1 : array[array.size - 1].to_i
  end

  def Priority.organize_priorities
    counter = 1
    Priority.get_all_data.each do |priority|
      priority.update_attributes!(:priority => counter)
      counter += 1
    end
  end

  def Priority.move_to_completed(li)
    CompletedPriority.create(
      :title => li.title,
      :description => li.description,
      :author => li.author,
      :assignee => li.assignee,
      :started => li.created_at,
      :finished => DateTime.now
    )  
    li.comments.destroy_all 
    li.destroy
  end

  def Priority.create_priority(title, description, priority, status, author, assignee)
    li = Priority.create(
        :title => title,
        :description => description,
        :priority => Priority.get_lowest_priority + 1,
        :status => status,
        :author => author,
        :assignee => assignee
    ) 
    return li
  end

  def Priority.add_priority(id, priority, old_priority)
    return if priority.to_i == old_priority.to_i || priority == nil || priority == ""
    list_item = Priority.find(id)
    priorities = Priority.get_all_used_priorities
    unless priorities.include? priority.to_i
      list_item.update_attributes!(:priority => priority)
      return
    end  
    current = priority.to_i
    while priorities.include? current
      current += 1
    end
    Priority.where("priority >= ? AND priority <= ?", priority, current).each do |li|
      li.update_attributes!(:priority => li.priority.to_i + 1)
    end
    list_item.update_attributes!(:priority => priority)
  end

  def Priority.update_priority(params)
    id = params[:id]
    title = params[:title]
    priority = params[:priority].to_i
    description = params[:description]
    status = params[:status]
    assignee = params[:assignee]

    li = Priority.find(id)
    updates = Priority.create_updates_hash(li, title, priority, description, status, assignee)
    PrioritiesComments.update_comment(id, updates)

    li.update_attributes!(
        :title => title,
        :description => description,
        :status => status,
        :assignee => assignee
    )
    Priority.add_priority(id, priority, li.priority)
  end

  def Priority.create_updates_hash(li, title, priority, description, status, assignee)
    updates = Hash.new
    if title != li.title
      updates["title"] = Hash.new
      updates["title"]= {"old_value" => li.title, "new_value" => title}
    end

    if priority != li.priority
      updates["priority"] = Hash.new
      updates["priority"]= {"old_value" => li.priority, "new_value" => priority}
    end

    if description != li.description
      updates["description"] = Hash.new
      updates["description"]= {"old_value" => li.description, "new_value" => description}
    end

    if status != li.status
      updates["status"] = Hash.new
      updates["status"]= {"old_value" => li.status, "new_value" => status}
    end

    if assignee != li.assignee
      updates["assignee"] = Hash.new
      updates["assignee"]= {"old_value" => li.assignee, "new_value" => assignee}
    end
    return updates
  end

#OUTPUTS
  def Priority.format_current_priorities_email
    stream = StringIO.new
    stream.puts("------------- CURRENT PRIORITIES -------------\n")
    Priority.get_all_data.each do |priority|
      stream.puts("-------------------------------------\n")
      stream.puts("Title: #{priority.title}\n")
      stream.puts("Description: #{priority.description}")
      stream.puts("Priority: #{priority.priority}\n")
      stream.puts("Status: #{priority.status}\n")
      stream.puts("Assignee: #{priority.assignee}\n")
    end
    open("/var/www/rails/links_engine/current/script/priorities/current_priorities_email.txt", 'w'){|f| f.puts stream.string}
  end

  def Priority.send_current_priorities_email(email)
    Priority.format_current_priorities_email
    Notifier.send_current_priorities_email(email).deliver
  end

  def Priority.format_completed_priorities_email(start_date, end_date)
    stream = StringIO.new
    stream.puts("------------- COMPLETED PRIORITIES: #{Date::MONTHNAMES[start_date.month]}, #{start_date.year} -------------\n")
    CompletedPriority.where("finished >= ? AND finished <= ?", start_date, end_date).order(:finished).each do |priority|
      stream.puts("-------------------------------------\n")
      stream.puts("Title: #{priority.title}\n")
      stream.puts("Description: #{priority.description}")
      stream.puts("Assignee: #{priority.assignee}\n")
      stream.puts("Finished: #{priority.finished.in_time_zone("Eastern Time (US & Canada)").strftime("%B #{priority.finished.day.ordinalize}, %Y %I:%M %p")}\n")
    end
    open("/var/www/rails/links_engine/current/script/priorities/completed_priorities_email.txt", 'w'){|f| f.puts stream.string}
  end

  def Priority.send_completed_priorities_email(email, start_date, end_date)
    Priority.format_completed_priorities_email(start_date, end_date)
    Notifier.send_completed_priorities_email(email, start_date, end_date).deliver
  end

#HTML Colors
  def Priority.get_color_by_status(li)
    case li.status
      when 'New'
        return 
      when 'Development' 
        return '#badee6'
      when 'Pushed'
        return '#a3e6aa'
      when 'Need More Info'
        return '#edebe6'
      when 'Cannot Complete'
        return '#8a8a8a'
    end
    return 'black'
  end

  def Priority.get_font_color_by_status(li)
    case li.status
      when 'New'
        return '#6ea1ba'
      when 'Development' 
        return '#234a4d'
      when 'Pushed'
        return '#0a8001'
      when 'Need More Info'
        return '#786e3d'
      when 'Cannot Complete'
        return '#800c01'
    end
    return 'black'
  end

  def Priority.get_user_color(user)
    case user
      when /jtp/i
        return '#ab0b00'
      when /bhill/i
        return 'purple'
      when /cguarino/i
        return 'blue'
      when /remiq/i
        return 'green'
      when /links engine/i
        return 'black; opacity: 0.5'
    end
    return 'black'
  end

end
