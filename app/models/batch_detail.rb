class BatchDetail < ActiveRecord::Base
  require 'csv'
  belongs_to :batch
 
  

  #attr_accessible :primer3_parameters_attributes, :step, :status, :gene, :grch37_start, :grch37_stop, :status, :batch_id, :cosmic_mut_id, 
  #                :bin, :chrom, :chrom_start, :chrom_end, :primer3_raw, :primer3_formatted, 
  #                :forward_base_pair_offset, :reverse_base_pair_offset

  STATUS_STEP = %w(select prepare locate sequence assay)
  STATUS_OPTIONS = %w(initialize processing completed error)
 
end
