class CreateUserScores < ActiveRecord::Migration
  def change
    create_table :user_scores, :id=>false do |t|
    	t.string :aid, :null => false
    	t.string :uuid, :null => false
    	t.text :link
	    t.decimal :p_score
	    t.decimal :c_score
	    t.decimal :d_score

      	t.timestamps
    end
    execute "ALTER TABLE user_scores ADD FOREIGN KEY (aid) REFERENCES newsarticles(aid);"
    execute "ALTER TABLE user_scores ADD FOREIGN KEY (uuid) REFERENCES uuid_tables(uuid);"
    add_index :user_scores, [:aid, :uuid], unique: true
  end
end
