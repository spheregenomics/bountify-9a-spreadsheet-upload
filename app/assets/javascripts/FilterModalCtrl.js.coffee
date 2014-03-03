angular.module('assaypipelineApp').controller "FilterModalCtrl", ($scope, $modalInstance, modalCriteriaList) ->
  console.log("ModalInstanceCtrlsss")
  $scope.modalCriteriaList = modalCriteriaList
  $scope.possible_conditions = [
    {id: "eq", name: "equals"}
    {id: "eq_any", name: "equals any"}
    {id: "eq_all", name: "equals all"}
    {id: "not_eq", name: "not equal to"}
    {id: "not_eq_any", name: "not equal to any"}
    {id: "not_eq_all", name: "not equal to all"}
    {id: "matches", name: "matches"}
    {id: "matches_any", name: "matches any"}
    {id: "matches_all", name: "matches all"}
    {id: "does_not_match", name: "doesn't match"}
    {id: "does_not_match_any", name: "doesn't match any"}
    {id: "does_not_match_all", name: "doesn't match all"}
    {id: "lt", name: "less than"}
    {id: "lt_any", name: "less than any"}
    {id: "lt_all", name: "less than all"}
    {id: "lteq", name: "less than or equal to"}
    {id: "lteq_any", name: "less than or equal to any"}
    {id: "lteq_all", name: "less than or equal to all"}
    {id: "gt", name: "greater than"}
    {id: "gt_any", name: "greater than any"}
    {id: "gt_all", name: "greater than all"}
    {id: "gteq", name: "greater than or equal to"}
    {id: "gteq_any", name: "greater than or equal to any"}
    {id: "gteq_all", name: "greater than or equal to all"}
    {id: "in", name: "in"}
    {id: "in_any", name: "in any"}
    {id: "in_all", name: "in all"}
    {id: "not_in", name: "not in"}
    {id: "not_in_any", name: "not in any"}
    {id: "not_in_all", name: "not in all"}
    {id: "cont", name: "contains"}
    {id: "cont_any", name: "contains any"}
    {id: "cont_all", name: "contains all"}
    {id: "not_cont", name: "doesn't contain"}
    {id: "not_cont_any", name: "doesn't contain any"}
    {id: "not_cont_all", name: "doesn't contain all"}
    {id: "start", name: "starts with"}
    {id: "start_any", name: "starts with any"}
    {id: "start_all", name: "starts with all"}
    {id: "not_start", name: "doesn't start with"}
    {id: "not_start_any", name: "doesn't start with any"}
    {id: "not_start_all", name: "doesn't start with all"}
    {id: "end", name: "ends with"}
    {id: "end_any", name: "ends with any"}
    {id: "end_all", name: "ends with all"}
    {id: "not_end", name: "doesn't end with"}
    {id: "not_end_any", name: "doesn't end with any"}
    {id: "not_end_all", name: "doesn't end with all"}
    {id: "true", name: "true"}
    {id: "false", name: "false"}
    {id: "present", name: "is present"}
    {id: "blank", name: "is blank"}
    {id: "null", name: "null"}
    {id: "not_null", name: "is not null"}]
    
  $scope.ok = ->
    $modalInstance.close $scope.modalCriteriaList
    $scope.assays = $scope.getPage
    return

  $scope.cancel = ->
    $modalInstance.dismiss "cancel"

  
  # return true if criteria can have more than one values
  $scope.multiFieldCriteria = (criteria) ->
    s = criteria.condition
    s.endsWith('_all') or s.endsWith('_any')

  # invokes via ng-change
  $scope.conditionChanged = (criteria) ->
    console.log("conditionChanged")
    unless $scope.multiFieldCriteria(criteria)
      criteria.values = [criteria.values.first()]

  $scope.conditionName = (id) ->
    ($scope.possible_conditions.find (x) ->
      x.id == id
    ).name

  $scope.activeWhenType = (type) ->
    console.log("activeWhenType: #{type}")
    if $scope.modalCriteriaList.type == type
      'active'
    else
      ''
      
      
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
    console.log("newCriteria from modal")
    {
      condition: 'eq'
      values: [{data: ''}]
    }
