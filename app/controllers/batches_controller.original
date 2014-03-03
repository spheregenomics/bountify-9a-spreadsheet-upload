require 'roo'
require 'axlsx'

class BatchesController < ApplicationController
  def new
    @batch = Batch.new
  end

  def create
    batch = Batch.new

    batch.description = params[:file].original_filename
    batch.assembly = params[:assembly]

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

      batch_detail.chrom = row['chrom']
      batch_detail.chrom_start = row['chrom_start'].to_i
      batch_detail.chrom_end = row['chrom_end'].to_i
    end

    batch.save

    respond_to do |format|
      format.json { render json: {:id => batch.id} }
    end
  end

  def show
    @batch = Batch.find(params[:id])
  end

  def download_xlsx
    Axlsx::Package.new do |p|
      # Required by Numbers.
      p.use_shared_strings = true

      p.workbook.add_worksheet(:name => 'Batch Details') do |sheet|
        sheet.add_row ["chrom", "chrom_start", "chrom_end"]

        params[:id].each do |batch_detail_id|
          batch_detail = BatchDetail.find(batch_detail_id)

          sheet.add_row [batch_detail.chrom, batch_detail.chrom_start, batch_detail.chrom_end]
        end
      end

      batch_id = BatchDetail.find(params[:id][0]).batch_id

      s = p.to_stream()

      send_data s.read, filename: "batch-details-for-batch-##{batch_id}.xlsx", type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
    end
  end
end
