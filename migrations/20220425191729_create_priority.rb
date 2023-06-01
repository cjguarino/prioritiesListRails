class CreatePriority < ActiveRecord::Migration
  def up
    create_table :priority do |table|
      table.integer :id, auto_increment: true, primary_key: true
      table.string :title, null: false
      table.text :description
      table.integer :priority, unique: true
      table.string :status
      table.string :author
      table.string :assignee
      table.timestamps
    end
  end

  def down
  end
end
