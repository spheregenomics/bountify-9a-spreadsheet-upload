angular.module('assaypipelineApp').controller "ConfigureModalCtrl", ($scope, $modalInstance, primer3) ->
  console.log("ConfigureModalCtrlssss")
  $scope.primer3 = primer3['data']
  console.log(JSON.stringify($scope.primer3,null,' '))
  
  $scope.ok = ->  
    $modalInstance.close $scope.primer3
    console.log("pressed ok")
    console.log(JSON.stringify($scope.primer3,null,' '))
    #$scope.assays = $scope.getPage
    return

  $scope.cancel = ->
    $modalInstance.dismiss "cancel"
    
  serverErrorHandler = ->
    alert("There was a server error, please reload the page and try again.")
    