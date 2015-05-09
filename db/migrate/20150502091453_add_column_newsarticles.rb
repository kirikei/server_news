class AddColumnNewsarticles < ActiveRecord::Migration
  def up
  	add_column :newsarticles, :category, :string
  end

  def down
  	remove_column :newsarticles, :category, :string
  end  
end
