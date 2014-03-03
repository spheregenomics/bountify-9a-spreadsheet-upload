
class Batch < ActiveRecord::Base
  attr_accessible :batch_details_attributes, :primer3_parameters_attributes, :batch, :step, :status, :status_timestamp, 
                  :description, :details, :user_id, :primer3_setting_id, :source, :name
  
  STEP_OPTIONS = %w(select prepare locate sequence assay)
  STATUS_OPTIONS = %w(initialize processing completed error)
  SOURCE_OPTIONS = %w(upload cosmic65 cosmic66 cosmic67)
  COSMIC_VERSIONS = %w(cosmic65 cosmic66 cosmic67)
  
  default_scope order('updated_at DESC')
  

  belongs_to :user
  has_many :batch_details, :dependent => :destroy

end


