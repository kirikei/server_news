class AddActionToHistories < ActiveRecord::Migration
  def change
  	add_column :histories, :action, :string
  end
end
