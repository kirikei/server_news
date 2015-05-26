class CreateMiddleScores < ActiveRecord::Migration
  def change
    create_table :middle_scores, :id=>false, :primary_key => :aid do |t|
    	t.string :aid, null: false
    	t.text :entity, null: false
    	t.text :polarity, null: false
    	t.text :core, null: false

      t.timestamps
    end
    execute "ALTER TABLE middle_scores ADD FOREIGN KEY (aid) REFERENCES newsarticles(aid);"
  end
end
