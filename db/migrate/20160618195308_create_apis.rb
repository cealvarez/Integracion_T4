class CreateApis < ActiveRecord::Migration
  def change
    create_table :apis do |t|
      t.string :consultar

      t.timestamps null: false
    end
  end
end
