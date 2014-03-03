angular.module('spreadsheetUpload').directive('resetForm', function() {
  return {
    link: function(scope, element, attrs) {
      scope[attrs.resetForm] = function() {
        scope[attrs.name].$setPristine()
        element[0].reset()
      }
    }
  }
})