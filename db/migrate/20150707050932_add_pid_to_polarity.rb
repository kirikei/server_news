class AddPidToPolarity < ActiveRecord::Migration
  def change
    add_column :polarities, :pid, :string
  end
end
