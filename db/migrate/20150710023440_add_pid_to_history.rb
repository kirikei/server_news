class AddPidToHistory < ActiveRecord::Migration
  def change
    add_column :histories, :pid, :string, :null => false
  end
end
