angular.module('assaypipelineApp').controller "PanelController", ($http, $resource, $scope, $routeParams, $modal, $location, Panel, Assay, Primer3Output, Primer3OutputPair, Primer3Parameter) ->
  $scope.sortMethod = 'priority'
  $scope.sortableEnabled = true
  
  # Column Filter Modal
  $scope.hiddenFields = []
  $scope.fieldsCriterias = []
  $scope.primer3Output = []
  
  # table
  $scope.numColumns = 12
  $scope.forwardOffset = 100
  $scope.reverseOffset = 100
  
  # array of selected checkbox rows
  $scope.selected = []
  
  $scope.localPrimer3 = {}
  

  $scope.init = () ->    
    @panelService = new Panel(serverErrorHandler)
    @panel_id = $routeParams.panel_id
    
    $scope.panel = @panelService.find $routeParams.panel_id
    $scope.currentPage = 1
    $scope.assays = $scope.getPage()

	
    $scope.fields =  [  {key: 'id', value: 'id'},
	                    {key: 'source', value: 'Source'}
		                {key: 'status', value: 'Status'},
		                {key: 'chrom', value: 'Chromosome'},
		                {key: 'chrom_start', value: 'Start'},
		                {key: 'chrom_end', value: 'Stop'},
		                {key: 'gene', value: 'Gene'},
		                {key: 'cosmic_mut_id', value: 'COSMIC Id'},
		                {key: 'primer_left', value: 'Left'},
		                {key: 'primer_right', value: 'Right'} ]            
 
  # ------------ panel info - should be a partial ----------------- #
  $scope.panelNameEdited = (panelName) ->
    @panelService.update(@panel, name: panelName)
    
  $scope.panelDescrEdited = (panelDescr) ->
    @panelService.update(@panel, description: panelDescr)
    
    
    
    
  # ----------------  code for hiding / showing of columns ------------------ #
  $scope.hideColumn = (field) ->
    console.log('hideColumn')  
    $("[key='#{field}']").hide()
    $scope.hiddenFields.push field
    if $scope.searchCriteriaListByField(field)
      $scope.fieldsCriterias.remove (x) ->
        x.field == field
      $scope.search()

  $scope.showAllColumns = ->
    console.log('showAllColumns')    
    $('[key]').show()
    $scope.hiddenFields = []
	
  $scope.searchCriteriaListByField = (field) ->
    $scope.fieldsCriterias.find (x) ->
      x['field'] == field

  $scope.iconWrenchAdditionalClass = (field) ->
    if $scope.searchCriteriaListByField(field)
      'red'
    else
      ''	
      
      

  # -------------  pagination  ----------------- #
  $scope.setPage = (newPage) ->
    console.log('setPage')
    newPage = 1 if newPage < 1
    $scope.currentPage = newPage
    $scope.getPage()
    
                 
                
  # ------------ exports ---------------------- #          
  $scope.exportXLS = ->
    console.log("$scope.exportXLS()")  
    queryString = decodeURIComponent($.param($scope.getPostParams()))
    location.href = "/api/batches/#{$routeParams.panel_id}/worksheet_export.xls?#{queryString}"    
      
  $scope.exportPDF = ->
      console.log("$scope.exportPDF()")
      queryString = decodeURIComponent($.param($scope.getPostParams()))
      location.href = "/api/batches/#{$routeParams.panel_id}/worksheet_export.pdf?#{queryString}"
      
  $scope.exportCSV = ->
    console.log("$scope.exportCSV()")  
    queryString = decodeURIComponent($.param($scope.getPostParams()))
    location.href = "/api/batches/#{$routeParams.panel_id}/worksheet_export.csv?#{queryString}"         
      
  $scope.exportSettings = ->
      console.log("$scope.exportSettings()")
        

  #  ---------   check box selection - TODO cleanup this code ------------- #
  # possible alternative http://jsfiddle.net/ProLoser/EUm7v/
  updateSelected = (action, id) ->
    $scope.selected.push id  if action is "add" & $scope.selected.indexOf(id) is -1
    $scope.selected.splice $scope.selected.indexOf(id), 1  if action is "remove" and $scope.selected.indexOf(id) isnt -1
    console.log("list of selections: #{$scope.selected}")
    
  $scope.updateSelection = ($event, id) ->
    checkbox = $event.target
    action = ((if checkbox.checked then "add" else "remove"))
    updateSelected action, id
  

  $scope.selectAll = ($event) ->
    checkbox = $event.target
    action = ((if checkbox.checked then "add" else "remove"))
    i = 0
    while i < $scope.assays.length
      entity = $scope.assays[i]
      updateSelected action, entity.id
      i++

  $scope.getSelectedClass = (entity) ->
    (if $scope.isSelected(entity.id) then "selected" else "")

  $scope.isSelected = (id) ->
    $scope.selected.indexOf(id) >= 0
    
    
        
  # ---------------- buttons ------------------- #
  $scope.lookupSequences = ->
    console.log('lookupSequences')
    http =
      method: "POST"
      url: "/api/batches/lookup_sequences"
      params:
        batch_id: @panel_id
        batch_detail_ids: $scope.selected
        forward_base_pair_offset: $scope.forwardOffset
        reverse_base_pair_offset: $scope.reverseOffset
    $http(http)
      .success ->
        console.log("sequence lookup submitted")
        # transfer to new page
      .error (response, status) ->
        alert("Error looking up sequences")
        
        
  $scope.getPage = ->
    console.log('getPage')
    http =
      method: "GET"
      url: "/api/batches/#{@panel_id}/batch_details/"    # TODO fix this
      params:
        page: $scope.currentPage
        q: $scope.getPostParams()
    $http(http)
      .success (response) ->
        console.log("sequence lookup submitted")
        console.log(JSON.stringify(response,null,' '))
        $scope.assays = response
      .error (response, status) ->
        alert("Error looking up sequences")
        
        
        
  $scope.createPrimers = ->
    console.log('createPrimers')
    http =
      method: "POST"
      url: "/api/batches/create_primers"
      params:
        batch_id: @panel_id
        batch_detail_ids: $scope.selected
    $http(http)
      .success ->
        console.log("createPrimers submitted")
        # transfer to new page
      .error (response, status) ->
        alert("Error createPrimers")
        
  



      
      
  # ------------- Search ------------- #
  $scope.search = ->
    searchParams =  $scope.getPostParams()
    console.log("search params:")
    console.log(JSON.stringify(searchParams,null,'  '))
    $.form(window.location.pathname, $scope.getPostParams(), 'GET').submit()
    
    

  # modal criteria search box
  # 'Constructor' for new criteria list
  $scope.newCriteriaList = (field, field_name) ->
    {
      type:  'AND'
      field:   field
      field_name: field_name
      criterias:  [$scope.newCriteria()]
    }  

  # 'Contructor' for new criteria
  $scope.newCriteria = ->
    {
      condition: 'eq'
      values: [{data: ''}]
    }


  $scope.modalCriteriaList = $scope.newCriteriaList('', '')

  $scope.searchCriteriaListByField = (field) ->
    $scope.fieldsCriterias.find (x) ->
      x['field'] == field
    
    

  # create ransack post params from fieldsCriterias
  $scope.getPostParams = ->
    # "q[g][0..][m]" - type (and/or)
    # "q[g][0..][c][0..]" - condition
    # "q[g][0..][c][0..][a][0][name]" - field
    # "q[g][0..][c][0..][p]" - param
    # "q[g][0..][c][0..][v][0..][value]" - values
    conditionGroupIndex = 0

    mainReductor = (result, criteriaList) ->
      conditionIndex = 0
      criteriaListReductor = (result, criteria) ->
        valueIndex = 0
        valuesReductor = (result, value) ->
          result.push {id: "q[g][#{conditionGroupIndex}][c][#{conditionIndex}][v][#{valueIndex}][value]", data: value.data}
          valueIndex++
          return result
        result.push {id: "q[g][#{conditionGroupIndex}][c][#{conditionIndex}][p]", data: criteria.condition}
        result.push {id: "q[g][#{conditionGroupIndex}][c][#{conditionIndex}][a][0][name]", data: criteriaList.field}
        result.push criteria.values.reduce(valuesReductor, [])
        conditionIndex++
        return result
      result.push {id: "q[g][#{conditionGroupIndex}][m]", data: criteriaList.type.underscore()}
      result.push criteriaList.criterias.reduce(criteriaListReductor, [])
      conditionGroupIndex++
      return result

    # i contruct intermediate array to use reduce() and be sure in code execution sequence
    result    = {}
    $scope.fieldsCriterias.reduce(mainReductor, []).flatten().each (x) ->
      result[x.id] = x.data

    hfIndex = 0
    $scope.hiddenFields.forEach (x) ->
      result["hf[#{hfIndex}]"] = x
      hfIndex++
    console.log("search result: #{result}")
    return result



  # -------------  filter modals ---------------- #
  $scope.invokeFilterModal = (field, field_name) ->
    console.log("invokeFilterModal")
    existing = $scope.searchCriteriaListByField field

    if existing?
      $scope.modalCriteriaList = existing
    else
      $scope.modalCriteriaList = $scope.newCriteriaList(field, field_name)
      $scope.fieldsCriterias.push $scope.modalCriteriaList
    modalInstance = $modal.open(
      templateUrl: '/templates/shared/criteria_modal.html'
      controller: 'FilterModalCtrl'
      resolve:
             modalCriteriaList: ->
               $scope.modalCriteriaList
    )
    modalInstance.result.then ((modalCriteriaList) ->
         $scope.modalCriteriaList = modalCriteriaList
         $scope.assays = $scope.getPage
         return
       ), ->
         console.log("Modal dismissed at: " + new Date())
         console.log
         return
         
         
        
  # ---------------- ucsc modal --------------------- #
  $scope.invokeUCSCModal = (chrom, chromStart, chromEnd) ->
    console.log("invokeUCSCModal")
    $scope.queryString = "http://genome.ucsc.edu/cgi-bin/hgTracks?org=human&db=hg19&position=chr#{chrom}:#{chromStart}-#{chromEnd}"
    modalInstance = $modal.open(
      templateUrl: '/templates/panel/ucsc_modal.html'
      controller: 'ucscModalCtrl'
      windowClass: 'ucsc-dialog'
      resolve:
             queryString: ->
               $scope.queryString
    )
    modalInstance.result.then ((modalCriteriaList) ->
         return
       ), ->
         return   
         
         
  # -------------- primer 3 configuration modal ----------------- #
  $scope.invokeConfigureModal = (assay_id) ->
    console.log("invokeConfigureModal")
    $scope.assay_id = assay_id
    $scope.primer3 = $scope.getPrimer(assay_id) 
    #console.log(JSON.stringify($scope.primer3,null,' '))
    #console.log("^")
    modalInstance = $modal.open(
      templateUrl: '/templates/configure_modal/configure_modal.html'
      controller: 'ConfigureModalCtrl'
      windowClass: 'configure-dialog'
      resolve:
             primer3: ->
               $scope.primer3
    )
    modalInstance.result.then ((selectedPair) ->
        $scope.putPrimer(primer3Data)
        return
       ), ->
        return   
               
    
  $scope.getPrimer = (assay_id) ->
    console.log('getPrimer')
    http =
      method: "GET"
      url: "/api/batch_details/#{$scope.assay_id}/primer3_parameters/"    # TODO fix this
    $http(http)
      .success (response) ->
        console.log("1. in get primer")
        console.log(JSON.stringify(response,null,' '))
        return response
      .error (response, status) ->
        alert("Errors")
        
        
        
  $scope.putPrimer = (primer3Data) ->
    console.log('putPrimer')
    http =
      method: "PUT"
      url: "/api/batch_details/#{$scope.assay_id}/primer3_parameters/"    # TODO fix this
      data: primer3Data
    $http(http)
      .success (response) ->
        console.log("put primer")
        console.log(JSON.stringify(response,null,' '))
      .error (response, status) ->
        alert("Errors")
     
         
         
  # ------------------ Assay Modal ------------------------ #         
  $scope.invokeAssayModal = (assay) ->
    $scope.assay = assay
    modalInstance = $modal.open(
      templateUrl: '/templates/panel/assay_modal.html'
      controller: 'AssayModalCtrl'
      windowClass: 'configure-dialog'
      resolve:
             assay: ->
               $scope.assay
    )
    modalInstance.result.then ((assay) ->
        $scope.assay = assay
        return
       ), ->
        return        
    


  serverErrorHandler = ->
    alert("There was a server error - please log a support ticket.")
    
    
    

    
   

    
