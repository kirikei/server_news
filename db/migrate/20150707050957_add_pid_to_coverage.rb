class AddPidToCoverage < ActiveRecord::Migration
  def change
    add_column :coverages, :pid, :string
  end
end
