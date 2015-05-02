class CreateCoverages < ActiveRecord::Migration
  def change
    create_table :coverages, :id=>false do |t|
	  t.string :aid, :null => false
	  t.float :score

      t.timestamps
    end
    execute "ALTER TABLE coverages ADD FOREIGN KEY (aid) REFERENCES newsarticles(aid);"
  end
end
