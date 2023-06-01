class PrioritiesComments < ActiveRecord::Base

  self.table_name = :priorities_comments
  self.primary_key = :id
  belongs_to :priorities

  def PrioritiesComments.get_all_comments 
    return PrioritiesComments.all.sort_by{|c| c.created_at}.reverse
  end

  def PrioritiesComments.create_comment(id, author, comment) 
    PrioritiesComments.create(
      :priority_id => id,
      :author => author,
      :comment => comment
    )
  end

  def PrioritiesComments.update_comment(id, updates)
    updates.each do |key, value|
      original = value["old_value"]
      new = value["new_value"]
      comment = "UPDATE: #{key} from '#{original}' to '#{new}'"
      PrioritiesComments.create(
        :priority_id => id,
        :comment => comment,
        :author => "Links Engine"
      )  
    end
  end

end


