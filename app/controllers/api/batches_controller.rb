require 'roo'    # spreadsheet uploads
require 'axlsx'  # spreadsheet downloads
class Api::BatchesController < Api::BaseController
  before_action :check_owner, only: [:show, :update, :destroy]
  
  FIELDS =    { source:         'Source',
	              status:         'Status',
	              chrom:          'Chromosome',
	              chrom_start:    'Start',
	              chrom_end:      'Stop',
	              gene:           'Gene',
	              cosmic_mut_id:  'COSMIC Id',
                primer_left:    'Left',
	              primer_right:   'Right'}       
                  

  def index
    Rails.logger.debug("index: #{current_user.batches.first.name}")
    render json: current_user.batches
  end

  def show
    render json: batch
  end

  def create
    Rails.logger.debug("create parms: #{safe_params}")
    panel = current_user.batches.create!(safe_params)
    render json: panel
  end
  

  def spreadsheet_upload
    Rails.logger.debug("here params: #{params}")
    batch = Batch.find(params[:id])

    batch.description = params[:file].original_filename
    batch.assembly = params[:assembly]
    batch.dataset = "Spreadsheet Upload"

    spreadsheet = nil

    case File.extname(params[:file].original_filename)
      when '.csv' then spreadsheet = Roo::CSV.new(params[:file].path)
      when '.xls' then spreadsheet = Roo::Excel.new(params[:file].path, nil, :ignore)
      when '.xlsx' then spreadsheet = Roo::Excelx.new(params[:file].path, nil, :ignore)
      else raise "Unknown file type: #{file.original_filename}"
    end

    spreadsheet_header = spreadsheet.row(1)

    (2..spreadsheet.last_row).each do |i|
      batch_detail = batch.batch_details.new
      # Alternative: row = Hash[*spreadsheet_header.zip(spreadsheet.row(i)).flatten]
      row = Hash[[spreadsheet_header, spreadsheet.row(i)].transpose]

      batch_detail.status = 'coords'
      batch_detail.chrom = row['chrom']
      batch_detail.chrom_start = row['chrom_start'].to_i
      batch_detail.chrom_end = row['chrom_end'].to_i
    end

    batch.save
    render json: {:id => batch.id}
    
    #respond_to do |format|
    #  format.json { render json: {:id => batch.id} }
    #end
  end
  

  
  def worksheet_export
    Rails.logger.debug "params: #{params}"
    if params[:q]
      @search = BatchDetail.where(:batch_id => params[:id]).search(params[:q])
      @batch_details = @search.result
    else
      @batch_details = BatchDetail.where(:batch_id => params[:id])
      Rails.logger.debug @batch_details
    end
    
    @hidden_columns = []
    @hidden_columns = params[:hf].values if params[:hf]
    @columns = Api::BatchesController::FIELDS.keys.map(&:to_s) - @hidden_columns

    respond_to do |format|
       format.csv { send_data BatchDetail.generate_csv(@batch_details, @columns),
                                                 type: Mime::CSV,
                                                 disposition: "attachment; filename=export-#{Date.today.to_s}.csv" }
       format.xls { download_xlsx(@batch_details, @columns) }
       format.pdf do
         pdf = PdfReport.new(@batch_details, @columns, view_context)
                 send_data pdf.render, filename: "panel.pdf",
                                       type: "application/pdf",
                                       disposition: "inline"
       end
    end
  end
  
  
  def download_xlsx(batch_details, columns)
    Rails.logger.debug("download_xlsx")
    Axlsx::Package.new do |p|
      p.use_shared_strings = true      # Required by numbers
      p.workbook.add_worksheet(:name => 'Panel') do |sheet|
        sheet.add_row columns    # header row
        batch_details.each do |row|
          row_data = []
          columns.each do |column|
            row_data << row.send(column)
          end  
          Rails.logger.debug("row: #{row_data}")
          sheet.add_row row_data
        end
      end
      s = p.to_stream()
      send_data s.read, filename: "Panel.xlsx", type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
    end
  end

  
  
  
  def create_details
    # TODO fix this: column "chrom_start" is of type integer but expression is of type character varying
    # TODO use pl/SQl for this kind of thing
    Rails.logger.debug("passed params: #{params}")
    batch_id = params[:batch_id]
    data_source_rows = params[:data_source_rows]
    data_source_rows = data_source_rows[1, data_source_rows.length - 2]   # cut off [] 
    #data_source_rows = JSON.parse(params[:data_source_rows])
    puts data_source_rows
    
    sql_insert = "insert into batch_details (batch_id,gene,status,chrom,chrom_start,chrom_end,cosmic_mut_id,source,created_at,updated_at) " +
                 "select #{batch_id},gene,'coords',chromosome,cast(grch37_start as integer),cast(grch37_stop as integer),cosmic_mut_id,'cosmic66',current_date,current_date " + 
                 "from cosmics where id in (#{data_source_rows})"   
    ActiveRecord::Base.connection.execute(sql_insert)
    render nothing: true   
  end
  
  
  def lookup_sequences
    Rails.logger.debug("passed params: #{params}")
    batch_id = params[:batch_id]
    batch_detail_ids = JSON.parse(params[:batch_detail_ids])
	  forward_base_pair_offset = params[:forward_base_pair_offset].to_i
	  reverse_base_pair_offset = params[:reverse_base_pair_offset].to_i
    Rails.logger.debug "About to call UCSC perform 2"
    Rails.logger.debug("#{batch_detail_ids} : #{forward_base_pair_offset} : #{reverse_base_pair_offset}")
    UcscQuery.perform(batch_detail_ids,forward_base_pair_offset,reverse_base_pair_offset)
    render nothing: true   
  end
  
  
  def create_primers
    Rails.logger.debug("passed params: #{params}")
    batch_id = params[:batch_id]
    batch_detail_ids = JSON.parse(params[:batch_detail_ids])
    Rails.logger.debug "About to call Primer 3 query"
    Rails.logger.debug("#{batch_detail_ids}")  
    Primer3Query.perform(batch_detail_ids)
    render nothing: true   
  end
  
  
  def assay_table
    Rails.logger.debug("assay table params: #{params}")
    @batch = Batch.find(params[:batch_id])
    #@batch_num = @batch.id
    @search = @batch.batch_details.search(params[:q])
    @batch_details = @search.result.paginate(:page => (params[:page] || 1), :per_page => 50)
    render json: @batch_details
   end


  def update
    batch.update_attributes(safe_params)
    render nothing: true
  end

  def destroy
    batch.destroy
    render nothing: true
  end

  private
  def check_owner
    permission_denied if current_user != batch.user
  end

  def batch
    @batch ||= Batch.find(params[:id])    
  end

  def safe_params
    Rails.logger.debug("safe_params")
    params.require(:panel).permit(:id, :batch, :step, :status, :status_timestamp, :description, :details, 
                                  :user_id, :primer3_setting_id, :source, :name)
  end
end

