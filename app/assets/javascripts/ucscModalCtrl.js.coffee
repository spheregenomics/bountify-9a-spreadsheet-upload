angular.module('assaypipelineApp').controller "ucscModalCtrl", ($scope, $modalInstance, queryString) ->
  console.log("UCSCModalCtrl")
  $scope.queryString = queryString
    
  $scope.cancel = ->
    $modalInstance.dismiss "cancel"
    
 
