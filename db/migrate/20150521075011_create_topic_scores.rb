class CreateTopicScores < ActiveRecord::Migration
  def change
    create_table :topic_scores, :id=>false do |t|
    	t.string :aid, null: false
    	t.text :entity, null: false
    	t.text :topic, null: false

      t.timestamps
    end
    add_index :topic_scores, [:aid, :entity], unique: true
  end
end
