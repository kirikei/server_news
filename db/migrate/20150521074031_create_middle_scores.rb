class CreateMiddleScores < ActiveRecord::Migration
  def change
    create_table :middle_scores, :id=>false, :primary_key => :aid do |t|
    	t.string :aid, null: false
    	t.text :entity
    	t.text :polarity
    	t.text :core

      t.timestamps
    end
    execute "ALTER TABLE middle_scores ADD FOREIGN KEY (aid) REFERENCES newsarticles(aid);"
  end
end
