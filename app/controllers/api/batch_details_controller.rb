class Api::BatchDetailsController < Api::BaseController
  before_action :check_owner

  def index
    @search = batch.batch_details
    @assays = @search.paginate(:page => (params[:page] || 1), :per_page => 3)
    
    render json: @assays
  end

  def create
    batch_detail = batch.batch_details.create!(safe_params)
    render json: batch_detail, status: 201
  end

  def update
    batch_detail.update_attributes(safe_params)
    render nothing: true, status: 204
  end

  def destroy
    batch_detail.destroy
    render nothing: true, status: 204
  end

  private
  def batch
    @batch ||= Batch.find(params[:batch_id])
  end

  def batch_detail
    @batch_detail ||= batch.batch_details.find(params[:id])
  end

  def safe_params
    params.require(:batch_detail).permit(:primer3_parameters_attributes, :step, :status, :gene, :grch37_start, :grch37_stop, :status, :batch_id, :cosmic_mut_id, 
                  :bin, :chrom, :chrom_start, :chrom_end, :primer3_raw, :primer3_formatted, 
                  :forward_base_pair_offset, :reverse_base_pair_offset)
  end

  def check_owner
    permission_denied if current_user != batch.user
  end
end
