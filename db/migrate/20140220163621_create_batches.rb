class CreateBatches < ActiveRecord::Migration
  def change
    create_table :batches do |t|
      t.string :status
      t.string :description
      t.string :assembly

      t.timestamps
    end
  end
end
