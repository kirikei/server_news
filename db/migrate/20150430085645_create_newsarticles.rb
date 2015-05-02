class CreateNewsarticles < ActiveRecord::Migration
  def change
    create_table :newsarticles, :id=>false, :primary_key => :aid do |t|
      t.string :aid, :null => false
      t.string :title
      t.string :image
      t.string :summary
      t.string :link
      t.string :text
      t.string :media
      t.string :pid
      t.string :pubDate

      t.timestamps
    end
    execute "ALTER TABLE newsarticles ADD PRIMARY KEY (aid);"
  end
end
