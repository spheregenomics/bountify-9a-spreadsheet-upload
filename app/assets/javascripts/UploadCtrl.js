angular.module('spreadsheetUpload').controller('UploadCtrl', ['$scope', '$upload', function($scope, $upload) {
  var file

  $scope.onFileSelect = function($files) {
    file = $files[0]
  }

  $scope.submitForm = function() {
    $scope.upload = $upload.upload({
      url: '/batches.json',
      data: {assembly: $scope.assembly},
      file: file
    }).success(function(data, status, headers, config) {
      $scope.resetForm()

      $scope.batchID = data.id
      $scope.uploaded = true
    })
  }
}])
