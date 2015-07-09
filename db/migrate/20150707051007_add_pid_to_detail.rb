class AddPidToDetail < ActiveRecord::Migration
  def change
    add_column :details, :pid, :string
  end
end
