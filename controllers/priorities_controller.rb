class PrioritiesController < ApplicationController

  if Rails.env.production?
    @@path = "/links/priorities"
  elsif Rails.env.staging?
    @@path = "/links2/priorities"
  end

  def animation
    render 'flash_animation'
  end

  def index
    @chosen_status = params[:chosen_status]
    @chosen_assignee = params[:chosen_assignee]
    @chosen_status = "Status(All)" if @chosen_status == nil || @chosen_status == ""
    @chosen_assignee = "Assignee(All)" if @chosen_assignee == nil || @chosen_assignee == ""  
    @status_array = Priority.get_status_array
    @status_choose = (Priority.get_status_array << "Status(All)").reverse
    @assignees = Priority.get_assignee_array
    @assignees_choose = (Priority.get_assignee_array << "Assignee(All)").reverse
    @list = Priority.get_data(@chosen_status, @chosen_assignee)
    if params[:id] != nil 
      redirect_to "#{@@path}/index#priority_list_#{params[:id]}"
    else
      render 'index'
    end
    return
  end

  def new
    title = params[:title]
    priority = params[:priority]
    descr = params[:description]
    status = params[:status]
    author = params[:author]
    assignee = params[:assignee]
    li = Priority.create_priority(title, descr, priority, status, author, assignee)
    Priority.add_priority(li.id, priority, li.priority)
    params[:id] = li.id
    index
    return
  end

  def update
    Priority.update_priority(params)
    index
    return
  end

  def delete
    begin
      priority = Priority.find(params[:id])
      PrioritiesComments.where(:priority_id => params[:id]).destroy_all
      priority.destroy
    rescue
      flash.now.alert = "Priority Deletion Error"
    end
    index
    return
  end

  def complete 
    Priority.move_to_completed(Priority.find(params[:id]))
    completed
    return
  end

  def completed
    @assignees_choose = (Priority.get_assignee_array << "Assignee(All)").reverse
    @chosen_assignee = params[:chosen_assignee]
    @chosen_assignee = "Assignee(All)" if @chosen_assignee == nil || @chosen_assignee == ""

    @year = params[:year]
    @month = params[:month]
    if params[:date] != nil
      params["date"].values.each do |val|
        val.length > 3 ? @year = val.to_i : @month = val.to_i
      end
    end
    @year = Date.today.year.to_i if @year == nil
    @month = Date.today.month.to_i if @month == nil
    @list = CompletedPriority.get_data(@year, @month, @chosen_assignee)
    @date = Date.parse("#{@year}-#{@month}-01")
    render 'completed'
    return
  end

  def organize_priorities
    Priority.organize_priorities
    index
    return
  end

  def send_current_email
    begin
      email = "#{params[:email]}@monmouth.com"
      raise "Email Error" if email.length < 1
    rescue
      index
      return
    end
    Priority.send_current_priorities_email(email)
    index
    return
  end

  def send_completed_email
    begin
      email = "#{params[:email]}@monmouth.com"
      start_date = Date.parse("#{params[:year]}-#{params[:month]}-01")
      end_date = start_date.next_month
      raise "Email Error" if email.length < 1
    rescue
      index
      return
    end
    Priority.send_completed_priorities_email(email, start_date, end_date)
    completed
    return
  end

  def add_comment
    priority_id = params[:priority_id]
    params[:id] = priority_id
    author = params[:author]
    comment = params[:comment]
    PrioritiesComments.create_comment(priority_id, author, comment)
    index
    return
  end

  def delete_comment
    comment_id = params[:id]
    comment = PrioritiesComments.find(comment_id)
    priority_id = comment.priority_id;
    params[:id] = priority_id
    comment.destroy
    index
    return
  end

  def recent_comments
    @comments = PrioritiesComments.get_all_comments
    render 'recent_comments'
    return
  end

end
