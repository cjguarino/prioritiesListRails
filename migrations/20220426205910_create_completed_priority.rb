class CreateCompletedPriority < ActiveRecord::Migration
  def up
    create_table :completed_priority do |table|
      table.integer :id, auto_increment: true, primary_key: true
      table.string :title, null: false
      table.text :description
      table.string :author
      table.string :assignee
      table.datetime :started
      table.datetime :finished
    end
  end

  def down
  end
end
