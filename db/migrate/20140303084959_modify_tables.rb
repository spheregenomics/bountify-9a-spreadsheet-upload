class ModifyTables < ActiveRecord::Migration
  def change
 

create_table "batch_details", force: true do |t|
  t.integer  "batch_id"
  t.string   "gene"
  t.string   "grch37_start"
  t.string   "grch37_stop"
  t.string   "status"
  t.datetime "created_at",               null: false
  t.datetime "updated_at",               null: false
  t.string   "hg19_coordinates"
  t.integer  "bin"
  t.string   "chrom"
  t.integer  "chrom_start"
  t.integer  "chrom_end"
  t.text     "dna"
  t.string   "cosmic_mut_id"
  t.text     "primer3_raw"
  t.text     "primer3_formatted"
  t.string   "step"
  t.string   "forward_base_pair_offset"
  t.string   "reverse_base_pair_offset"
  t.string   "source"
  t.integer  "forward_offset"
  t.integer  "reverse_offset"
  t.string   "primer_left"
  t.string   "primer_right"
end

create_table "batches", force: true do |t|
  t.string   "status"
  t.datetime "status_timestamp"
  t.datetime "created_at",         null: false
  t.datetime "updated_at",         null: false
  t.string   "description"
  t.text     "details"
  t.integer  "user_id"
  t.integer  "primer3_setting_id"
  t.string   "name"
  t.string   "assembly"
  t.string   "dataset"
  t.integer  "dataset_id"
end

add_index "batch_details", ["batch_id"], name: "index_batch_details_on_batch_id", using: :btree

end
end