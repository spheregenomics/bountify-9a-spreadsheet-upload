module ApplicationHelper
  def active_if_current(path)
    'active' if current_page?(path)
  end
  

  def display_base_errors resource
    return '' if (resource.errors.empty?) or (resource.errors[:base].empty?)
    messages = resource.errors[:base].map { |msg| content_tag(:p, msg) }.join
    html = <<-HTML
    <div class="alert alert-error alert-block">
      <button type="button" class="close" data-dismiss="alert">&#215;</button>
      #{messages}
    </div>
    HTML
    html.html_safe
  end
  

  def link_to_add_fields(name, f, type)
    new_object = f.object.send "build_#{type}"
    id = "new_#{type}"
    fields = f.send("#{type}_fields", new_object, child_index: id) do |builder|
      render(type.to_s + "_fields", f: builder)
    end
    link_to(name, '#', class: "add_fields", data: {id: id, fields: fields.gsub("\n", "")})
  end


  def page_entries_info(collection, options = {})
    entry_name = options[:entry_name] || (collection.empty?? 'item' :
        collection.first.class.name.split('::').last.titleize)
    if collection.total_pages < 2
      case collection.size
      when 0; "No #{entry_name.pluralize} found"
      else; "Displaying all #{entry_name.pluralize}"
      end
    else
      %{Displaying %d - %d of %d #{entry_name.pluralize}} % [
        collection.offset + 1,
        collection.offset + collection.length,
        collection.total_entries
      ]
    end
  end
  
  def sortable(column, title = nil)
     title ||= column.titleize
     direction = (column == sort_column && sort_direction == "asc") ? "desc" : "asc"
     link_to title, :sort => column, :direction => direction
   end
   

   def params_to_ng(params, fields_names_hash, hidden_fields)
     result = ""
     def ng_init_span(js)
       "<span ng-init=\"#{js}\"></span>"
     end

     params = {'g' => {}} unless params and params['g']
     params['g'].values.each do |group|
       criterias = []
       field = nil
       group['c'].values.each do |criteria|
         field     = criteria['a']['0']['name']
         condition = criteria['p']
         values    = []

         criteria['v'].values.each{ |v| values << "{data: '#{v['value']}'}" }
         criterias << "{condition: '#{condition}', values: [#{values.join(',')}] }"
       end

       type = group['m'].upcase
       result << ng_init_span("fieldsCriterias.push({type: '#{type}', field: '#{field}', field_name: '#{fields_names_hash[field.to_sym]}', criterias: [#{criterias.join(',')}]})")
     end

     return result.html_safe unless hidden_fields
     hidden_fields.each do |field|
       result << ng_init_span("hideColumn('#{field}')")
     end

     result.html_safe
   end

end
