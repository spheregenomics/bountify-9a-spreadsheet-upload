class CreateBatchDetails < ActiveRecord::Migration
  def change
    create_table :batch_details do |t|
      t.references :batch, index: true
      t.string :chrom
      t.integer :chrom_start
      t.integer :chrom_end
    end
  end
end
