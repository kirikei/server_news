class CreateUuidTables < ActiveRecord::Migration
  def change
    create_table :uuid_tables, :id=>false, :primary_key => :uuid do |t|
      t.string :uuid, :null => false

      t.timestamps
    end
  end
end
