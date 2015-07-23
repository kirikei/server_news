class AddAnalyzedAtToNewsartile < ActiveRecord::Migration
  def change
  	add_column :newsarticles, :analyzed_at, :timestamp
  end
end
