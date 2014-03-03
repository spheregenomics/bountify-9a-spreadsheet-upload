class WizardsController < ApplicationController
  require 'roo'
  include Roo
  # The Wizard state controls which page is visible and what fields are active
  # Each batch also has a step and status which are independent from the wizard state
  # A batch can be left half done and picked up at any time
  # Clicking on the :start tab of the wizard always drops the current batch from the wizard state
  
  FIELDS =  {
              cosmic_mut_id:    'COSMIC Id',
              gene:             'Gene',
              accession_number: 'Accession Number',
              mut_description:  'Description',
              mut_syntax_cds:   'Mut Syntax CDs',
              mut_syntax_aa:    'Mut Syntax AA',
              chromosome:       'Chromosome',
              grch37_start:     'Start',
              grch37_stop:      'Stop',
              mut_nt:           'Mut NT',
              mut_aa:           'Mut AA',
              tumour_site:      'Tumour Site',
              mutated_samples:  'Mutated Samples',
              examined_samples: 'Examined Samples',
              mut_freq:         'Mut Freq',
              stanford:         'Stanford',
              vogel:            'Vogelstein',
              ampliseq:         'Ampliseq'
            }

      

  def import
    @batch = Batch.import(params[:file],current_user)
    #redirect_to root_url, notice: "Spreadsheet imported."
    #Rails.logger.debug "About to call UCSC perform"
    #UcscQuery.perform(@batch,150,150)
    #redirect_to locate_url(@batch.id)
    redirect_to edit_batch_path(@batch)
  end

  def update
    @batch = Batch.create!(:user_id => current_user.id,
                           :primer3_setting_id => 2,
                           :source => 'cosmic66')
    @batch.description =  "Batch: #{@batch.id}"
    @batch.save

    if params[:select_all]
      q = JSON.parse(params[:query_json])
      data = Cosmic.search(q).result.pluck(:cosmic_mut_id)

    else
      data = params[:cosmic_mut_ids]
    end
    
    # TODO Base this on cosmics.id instead of cosmics_mut_id as there are some dups
    data.each do |cosmic_mut_id|
      @batch_detail = BatchDetail.create!(:batch_id => @batch.id,
                                          :cosmic_mut_id => cosmic_mut_id,
                                          :status => 'ready')
      @batch_detail.save
    end
  
    #@batch_num = @batch.id
	   #forward_base_pair_offset = params[:forward_base_pair_offset].to_i
	   #reverse_base_pair_offset = params[:reverse_base_pair_offset].to_i
    #Rails.logger.debug "About to call UCSC perform 2"
    #UcscQuery.perform(@batch,forward_base_pair_offset,reverse_base_pair_offset)
    #redirect_to locate_url(@batch_num)
    #redirect_to locate_url(@batch.id)
    redirect_to edit_batch_path(@batch)
  end

  def start
    @state = :start
    @batch_num = 0
    @batches = Batch.all
    render 'start/start'
  end


  def select
    @state = :select
    @batch_num = 0
    @search = Cosmic.search(params[:q])
    @cosmics = @search.result.paginate(:page => params[:page])
    @search.build_condition
    @fields = FIELDS
    render 'select/select'
  end


  def export
    @search = Cosmic.search(params[:q])
    @cosmics = @search.result
    
    @hidden_fields = []
    @hidden_fields = params[:hf].values if params[:hf]

    respond_to do |format|
      format.csv { send_data Cosmic.generate_csv(@cosmics, FIELDS.keys.map(&:to_s) - @hidden_fields),
                             type: Mime::CSV,
                             disposition: "attachment; filename=export-#{Date.today.to_s}.csv" }
    end
  end
  
  

  def worksheet_export
    x = params[:id]

    Rails.logger.debug "idx: #{x.methods.sort}"
    Rails.logger.debug "params: #{params}"
    if params[:q]
      Rails.logger.debug "if"
      @search = BatchDetail.where(:batch_id => params[:id]).search(params[:q])
      @batch_details = @search.result
    else
      Rails.logger.debug "else"
      @batch_details = BatchDetail.where(:batch_id => params[:id])
      Rails.logger.debug @batch_details
    end
    @hidden_fields = []
    @hidden_fields = params[:hf].values if params[:hf]

    respond_to do |format|
       format.csv { send_data BatchDetail.generate_csv(@batch_details, BatchesController::FIELDS.keys.map(&:to_s) - @hidden_fields),
                                                 type: Mime::CSV,
                                                 disposition: "attachment; filename=export-#{Date.today.to_s}.csv" }
    end
end

  def search
    render 'select/select'
  end

  def selected # lookup is ready
    @state = :selected
    @batch_num = 0
  end




  def locate_btn
    Rails.logger.debug("sean btn params: #{params}")
     @batch = Batch.create!(:user_id => current_user.id,
                            :primer3_setting_id => 2,
                            :source => 'cosmic66')
     @batch.description =  "Batch: #{@batch.id}"
     @batch.save

     if params[:select_all]
       q = JSON.parse(params[:query_json])
       data = Cosmic.search(q).result.pluck(:cosmic_mut_id)

     else
       data = params[:cosmic_mut_ids]
     end
     
     # TODO Base this on cosmics.id instead of cosmics_mut_id as there are some dups
     data.each do |cosmic_mut_id|
       @batch_detail = BatchDetail.create!(:batch_id => @batch.id,
                                           :cosmic_mut_id => cosmic_mut_id,
                                           :status => 'ready')
       @batch_detail.save
     end
   
     #@batch_num = @batch.id
 	   #forward_base_pair_offset = params[:forward_base_pair_offset].to_i
 	   #reverse_base_pair_offset = params[:reverse_base_pair_offset].to_i
     #Rails.logger.debug "About to call UCSC perform 2"
     #UcscQuery.perform(@batch,forward_base_pair_offset,reverse_base_pair_offset)
     #redirect_to locate_url(@batch_num)
     #redirect_to locate_url(@batch.id)
     redirect_to edit_batch_path(@batch)
     
   end
   
   def worksheet_btn
     batch_detail_ids = params[:batch_detail_ids]
     case params[:buttonPressed]
       when 'create-primer-btn'
         Rails.logger.debug 'create-primer-btn'
         Primer3Query.perform(batch_detail_ids)
       when 'lookup-seq-btn'
         Rails.logger.debug 'lookup-seq-btn'
     	   forward_base_pair_offset = params[:forward_base_pair_offset].to_i
     	   reverse_base_pair_offset = params[:reverse_base_pair_offset].to_i
         Rails.logger.debug "About to call UCSC perform 2"
         UcscQuery.perform(batch_detail_ids,forward_base_pair_offset,reverse_base_pair_offset)
       when 'configure-btn'
         Rails.logger.debug 'configure-btn'
         
       when 'order-primer-btn'
         Rails.logger.debug 'order-primer-btn'
       when 'mass-delete-btn'
         Rails.logger.debug 'mass-delete-btn'
         BatchDetail.delete batch_detail_ids
       else
         Rails.logger.debug 'something else'
     end 
     redirect_to edit_batch_path(params[:batch_id])
   end


  def locate
    @state = :locate
    @batch_num = params[:id]
    @batch = Batch.find(@batch_num)
    if @batch.step == 'configure' && @batch.status = 'ready'
      respond_to do |format|
        format.html { redirect_to configure_url(@batch_num) }
        format.json { render json: {'status' => 'ready'} }
      end
    else
      respond_to do |format|
        format.html { render 'batches/show' }
        format.json { render json: {'status' => 'processing'} }
      end
    end
  end


  def configure
    @state = :configure
    @batch_num = params[:id]
    @batch = Batch.find(@batch_num)
    render 'batches/edit'
  end


  def primer3_btn    # primer3 button pressed
    @state = :primer3
    @batch_num = params[:id]
    @batch = Batch.find(@batch_num)
    Rails.logger.debug "About to call Primer3Query"
    Primer3Query.perform(@batch.id)
    redirect_to assay_url(@batch_num)
  end


  def primer3  # primer 3 processing, tab is yellow
    @state = :primer3
    @batch_num = params[:id]
    @batch = Batch.find(@batch_num)
    if @batch.step == 'assay' && @batch.status == 'completed'  ## This needs to be done via javascript
      redirect_to assay_url(@batch_num)
    else
      #render 'batches/show'
      #render 'batches/edit'
      redirect_to edit_batch_path(@batch_num)
    end
  end


  def assay # display the assay results
    @state = :assay
    @batch_num = params[:id]
    @batch = Batch.find(@batch_num)
    render 'batches/show'
  end

  #def batch_state
  #  @batch = Batch.find(params[:id])
  #  render :json => { :batch_step => @batch.step, :batch_status => @batch.status }
  #end

  #def splinter
  #  SplinterQuery.perform(params[:id])
  #end

end
