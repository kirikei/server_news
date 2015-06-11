class CreateDetails < ActiveRecord::Migration
  def change
    create_table :details, :id=>false do |t|
	  t.string :aid, :null => false, :unique => true
	  t.decimal :score

      t.timestamps
    end
    execute "ALTER TABLE details ADD FOREIGN KEY (aid) REFERENCES newsarticles(aid);"
  end
end