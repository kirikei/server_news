class CreateUuidTables < ActiveRecord::Migration
  def change
    create_table :uuid_tables, :id=>false, :primary_key => :uuid do |t|
      t.string :uuid, :null => false, :unique => true

      t.timestamps
    end
    execute "ALTER TABLE uuid_tables ADD PRIMARY KEY (uuid);"
  end
end
