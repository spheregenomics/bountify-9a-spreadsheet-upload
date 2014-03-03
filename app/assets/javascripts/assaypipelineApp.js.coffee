assaypipelineApp = angular.module('assaypipelineApp', ['ngResource', 'mk.editablespan', 'ui.sortable','ui.bootstrap','angularFileUpload','ui.select2'])

assaypipelineApp.config ($httpProvider) ->
  authToken = $("meta[name=\"csrf-token\"]").attr("content")
  $httpProvider.defaults.headers.common["X-CSRF-TOKEN"] = authToken

assaypipelineApp.config ($routeProvider, $locationProvider) ->
  $locationProvider.html5Mode true
  $routeProvider.when '/', redirectTo: '/dashboard'
  $routeProvider.when '/dashboard',                  templateUrl: '/templates/dashboard/dashboard.html',    controller: 'DashboardController'
  $routeProvider.when '/selectdataset/:panel_id',    templateUrl: '/templates/dataset/select_dataset.html', controller: 'SelectDatasetController'
  $routeProvider.when '/dataset/:panel_id',          templateUrl: '/templates/dataset/dataset.html',        controller: 'DatasetController'
  $routeProvider.when '/batches/:panel_id',          templateUrl: '/templates/panel/panel.html',            controller: 'PanelController'   

# Makes AngularJS work with turbolinks.
$(document).on 'page:load', ->
  $('[ng-app]').each ->
    module = $(this).attr('ng-app')
    angular.bootstrap(this, [module])
