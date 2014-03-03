angular.module('spreadsheetUpload').controller('ShowCtrl', ['$scope', function($scope) {
  $scope.selected = []

  var updateSelected = function(action, id) {
    if (action === 'add' && $scope.selected.indexOf(id) === -1) {
      $scope.selected.push(id)
    }

    if (action === 'remove' && $scope.selected.indexOf(id) !== -1) {
      $scope.selected.splice($scope.selected.indexOf(id), 1)
    }

    $scope.selectedURLFormat = '?'

    for (var i = 0; i < $scope.selected.length; i++) {
      $scope.selectedURLFormat += 'id[]=' + $scope.selected[i]

      if(i !== ($scope.selected.length - 1)) {
        $scope.selectedURLFormat += '&'
      }
    }
  }

  $scope.updateSelection = function(checked, id) {
    var action = (checked ? 'add' : 'remove')

    updateSelected(action, id)
  }

  $scope.isSelected = function(id) {
    return $scope.selected.indexOf(id) >= 0
  }
}])
