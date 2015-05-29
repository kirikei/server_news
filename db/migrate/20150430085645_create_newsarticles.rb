class CreateNewsarticles < ActiveRecord::Migration
  def change
    create_table :newsarticles, :id=>false, :primary_key => :aid do |t|
      t.string :aid, :null => false
      t.text :title
      t.text :image
      t.text :summary
      t.text :link
      t.text :text
      t.text :media
      t.text :pid
      t.text :pubdate

      t.timestamps
    end
    execute "ALTER TABLE newsarticles ADD PRIMARY KEY (aid);"
  end
end
