class CompletedPriority < ActiveRecord::Base

  self.table_name = :completed_priority
  self.primary_key = :id

  def CompletedPriority.get_data(year = nil, month = nil, assignee)
    if year == nil || month == nil
      if assignee == "Assignee(All)"
        return CompletedPriority.all.sort_by{|x| x.finished}.reverse
      end
      return CompletedPriority.where(:assignee => assignee).sort_by{|x| x.finished}.reverse
    else
      start_date = Date.parse("#{year}/#{month}/1")
      end_date = start_date.next_month
      if assignee == "Assignee(All)"
        return CompletedPriority.where("finished >= ? AND finished < ?", start_date, end_date).sort_by{|x| x.finished}.reverse
      end
      return CompletedPriority.where("assignee = ? AND finished >= ? AND finished < ?", assignee, start_date, end_date).sort_by{|x| x.finished}.reverse
    end
  end

end
