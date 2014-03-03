var app = angular.module('spreadsheetUpload', ['angularFileUpload'])

app.config(['$httpProvider', function($httpProvider) {
  $httpProvider.defaults.headers.common['X-CSRF-Token'] = $('meta[name=csrf-token]').attr('content')
}])

// Bootstrap Angular app when the page has loaded. This ensures that the app is
// properly initialized when the page is only partially reloaded by Turbolinks.
// See http://stackoverflow.com/a/15488920.
$(document).on('ready page:load', function() {
  angular.bootstrap(document.body, ['spreadsheetUpload'])
})
