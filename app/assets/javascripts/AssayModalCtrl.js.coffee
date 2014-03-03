angular.module('assaypipelineApp').controller "AssayModalCtrl", ($http, $resource, $scope, $modalInstance, Primer3Output, Primer3OutputPair, assay) ->
  console.log("ConfigureAssayCtrl")
  $scope.assay = assay
  console.log("assay id: #{$scope.assay.id}")
  
  $scope.open = () ->
    console.log("about to call get primer")       
    $scope.primerOutput = $scope.getPrimerOutput($scope.assay)
    

  
  $scope.getPrimerOutput = (assay) ->
    console.log('getPrimer')
    http =
      method: "GET"
      url: "/api/batch_details/#{$scope.assay.id}/primer3_outputs/"    # TODO fix this
    $http(http)
       .success (response) ->
         console.log("in get primer")
         console.log(JSON.stringify(response,null,' '))
         $scope.primerOutput = response
         $scope.primerPairs = $scope.getPrimerPairs($scope.primerOutput)
         #return response
       .error (response, status) ->
         alert("Errors")
         
         
  $scope.getPrimerPairs = ()->
    console.log("getPrimerPairs: #{$scope.primerOutput.id}")
    http =
      method: "GET"
      url: "/api/primer3_outputs/#{$scope.primerOutput.id}/primer3_output_pairs/"  # TODO fix this
    $http(http)
       .success (response) ->
         console.log("in get primer pairs")
         console.log(JSON.stringify(response,null,' '))
         $scope.primerPairs = response
         #return response
       .error (response, status) ->
         alert("Errors")
         
         
  $scope.updateSelectedPair = (id) ->
      console.log("parms: #{id} - #{$scope.primerOutput.id}")
      http =
          method: "PATCH"
          url: "/api/primer3_outputs/#{$scope.primerOutput.id}/primer3_output_pairs/#{id}"
      $http(http)
        .success (response) ->
            console.log("update successful")
        .error (response, status) ->
            alert("updated failed")
      
      
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
  


  $scope.ok = ->
    $modalInstance.close $scope.assay
    #$scope.assays = $scope.getPage
    #return


  $scope.cancel = ->
    $modalInstance.dismiss "cancel"
    
    
  $scope.select = (primerPair) ->
    $scope.updateSelectedPair(primerPair.id)
    $scope.assay.primer_left = primerPair.primer_left_sequence
    $scope.assay.primer_right = primerPair.primer_right_sequence   
    console.log("refreshNeeded")
    # update primer3_output_pairs set selected = t where id = primerPair.id
    # update batch_detail set left / right seq = primerPairs.left / right seq where id = primerPair.batch_detail_id

  serverErrorHandler = ->
    alert("There was a server error, please reload the page and try again.")
    
  $scope.open()
 


