class CreatePrioritiesComments < ActiveRecord::Migration
  def up
    create_table :priorities_comments do |table|
      table.integer :id, auto_increment: true, primary_key: true
      table.integer :priority_id
      table.text :comment
      table.string :author
      table.timestamps
    end
  end

  def down
  end
end
