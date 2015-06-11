class CreatePolarities < ActiveRecord::Migration
  def change
    create_table :polarities, :id=>false do |t|
	  t.string :aid, :null => false, :unique => true
	  t.decimal :score

      t.timestamps
    end
    execute "ALTER TABLE polarities ADD FOREIGN KEY (aid) REFERENCES newsarticles(aid);"
  end
end
