

@SearchCtrl = ($scope) ->
  # Main data storage
  # We store all current criterias inside this
  # it's array of criteria lists (see below)
  $scope.fieldsCriterias = []

  # Array of strings. Indicates what columns is hidden.
  $scope.hiddenFields = []

  # used via ng-init
  $scope.init = ->
    $(document).ready ->
      $('#editCriteriasModal').on 'hidden', ->
        $scope.$apply ->
          $scope.criteriaListValidation $scope.modalCriteriaList
          $scope.search()

  # 'Constructor' for new criteria list
  $scope.newCriteriaList = (field, field_name) ->
    {
      type:       'AND'
      field:      field
      field_name: field_name
      criterias:  [$scope.newCriteria()]
    }

  # 'Contructor' for new criteria
  $scope.newCriteria = ->
    {
      condition: 'eq'
      values: [{data: ''}]
    }

  # it used by modal dialog
  $scope.modalCriteriaList = $scope.newCriteriaList('', '')


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

    return result

  # invokes by ng-click
  $scope.search = ->
    $.form(window.location.pathname, $scope.getPostParams(), 'GET').submit()

  $scope.exportCSV = ->
    location.href = "/wizards/export.csv?#{Object.toQueryString($scope.getPostParams())}"
	
  

  # remove incorrect(empty) criterias. And removes itself if no criterias left.
  $scope.criteriaListValidation = (list) ->
    list.criterias.remove (criteria) ->
      criteria.values.remove (value) ->
        value.data.compact() == ''
      criteria.values.isEmpty()

    if list.criterias.isEmpty()
      index = $scope.fieldsCriterias.findIndex (x) ->
        x.field == list.field
      $scope.fieldsCriterias.removeAt index

  $scope.searchCriteriaListByField = (field) ->
    $scope.fieldsCriterias.find (x) ->
      x['field'] == field

  $scope.iconWrenchAdditionalClass = (field) ->
    if $scope.searchCriteriaListByField(field)
      'red'
    else
      ''

  $scope.hideColumn = (field) ->
    $("[key='#{field}']").hide()
    $scope.hiddenFields.push field
    if $scope.searchCriteriaListByField(field)
      $scope.fieldsCriterias.remove (x) ->
        x.field == field
      $scope.search()

  $scope.showAllColumns = ->
    $('[key]').show()
    $scope.hiddenFields = []

  # show editor modal
  $scope.invokeModal = (field, field_name) ->
    existing = $scope.searchCriteriaListByField field

    if existing?
      $scope.modalCriteriaList = existing
    else
      $scope.modalCriteriaList = $scope.newCriteriaList(field, field_name)
      $scope.fieldsCriterias.push $scope.modalCriteriaList

    $("#editCriteriasModal").modal('show')

  # return true if criteria can have more than one values
  $scope.multiFieldCriteria = (criteria) ->
    s = criteria.condition
    s.endsWith('_all') or s.endsWith('_any')

  # invokes via ng-change
  $scope.conditionChanged = (criteria) ->
    unless $scope.multiFieldCriteria(criteria)
      criteria.values = [criteria.values.first()]

  $scope.conditionName = (id) ->
    ($scope.possible_conditions.find (x) ->
      x.id == id
    ).name

  $scope.activeWhenType = (type) ->
    if $scope.modalCriteriaList.type == type
      'active'
    else
      ''

  # keep this at the end of the file
  # it's possible conditions list for ng-options
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
    {id: "not_null", name: "is not null"}
  ]
