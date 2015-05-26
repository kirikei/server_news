class CreateHistories < ActiveRecord::Migration
  def change
    create_table :histories do |t|
      t.string :aid, :null => false
      t.string :uuid, :null => false
      t.integer :time

      t.timestamps
    end
    execute "ALTER TABLE histories ADD FOREIGN KEY (aid) REFERENCES newsarticles(aid);"
    execute "ALTER TABLE histories ADD FOREIGN KEY (uuid) REFERENCES uuid_tables(uuid);"
  end
end