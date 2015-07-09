class AddPidToUserscore < ActiveRecord::Migration
  def change
    add_column :user_scores, :pid, :string
  end
end
