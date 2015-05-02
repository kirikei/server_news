class CreateDetails < ActiveRecord::Migration
  def change
    create_table :details, :id=>false do |t|
	  t.string :aid, :null => false
	  t.float :score

      t.timestamps
    end
    execute "ALTER TABLE details ADD FOREIGN KEY (aid) REFERENCES newsarticles(aid);"
  end
end
