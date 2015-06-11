class CreateCoverages < ActiveRecord::Migration
  def change
    create_table :coverages, :id=>false do |t|
	  t.string :aid, :null => false, :unique => true
	  t.decimal :score

      t.timestamps
    end
    execute "ALTER TABLE coverages ADD FOREIGN KEY (aid) REFERENCES newsarticles(aid);"
  end
end

