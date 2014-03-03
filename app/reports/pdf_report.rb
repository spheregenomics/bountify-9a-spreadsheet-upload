class PdfReport < Prawn::Document
  def initialize(batch_details, columns, view_context)
    super(top_margin: 70)
    @batch_details = batch_details
    @columns = columns
    @view = view_context
    header
    report_body
    footer
  end
  
  def header
    #text @columns, size: 30, style: :bold
  end

  def report_body
    Rails.logger.debug("report_body #{@batch_details} --  #{@columns}")
    move_down 20
    @batch_details.each do |row|
      row_data = []
      @columns.each do |column|
        row_data << row.send(column)
      end  
      Rails.logger.debug("row: #{row_data}")
      text "#{row_data}"
    end
  end
  
  def footer
    text "Panel", size: 30, style: :bold
  end
end