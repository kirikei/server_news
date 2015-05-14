class CreateHistories < ActiveRecord::Migration
  def change
    create_table :histories, :id=>false do |t|
      t.string :aid, :null => false
      t.string :uuid, :null => false
      t.string :link
	    t.float :p_score
	    t.float :c_score
	    t.float :d_score

      t.timestamps
    end
    execute "ALTER TABLE histories ADD FOREIGN KEY (aid) REFERENCES newsarticles(aid);"
  end
end