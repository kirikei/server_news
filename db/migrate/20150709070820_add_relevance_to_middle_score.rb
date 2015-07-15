class AddRelevanceToMiddleScore < ActiveRecord::Migration
  def change
    add_column :middle_scores, :relevance, :decimal
  end
end
