# Overview
The code that I need help with manages a read-only table. 
It has the following features which are all working now:

1. Semi-dynamic table definition - driven by a hash ($scope.fields)
2. Modals for each column which allow a complex search criteria to be entered. Search is executeds via 
the Ransack gem and a complex object is created and sent to the server for the search
3. Pagination via the will_paginate gem
4. Check box selection on the left column
   - the selected rows can then be processed by a number of buttons added to the table header
5. Table sorting by clicking on the header (not sure if this still works)
6. XLS / CSV / PDF export works from currently filtered rows and columns
7. The table is expected to be a detail row for the header on the page. ie: the page is for batches and
  the table is for batch_details


# Setup
- If you run the latest migration 20140220163621_create_batches.rb it will create the batches tables
- seeds.rb has some dumps from my dev database for these tables. 
- batch_ids of 1006, 1072, 1055, 1075 998 would be good for testing
- Gemfile2 is the original project gemfile
- Some older versions of the code that may help you are in doc/oldfiles 



# Requirements
0. Table should be generic so any rails model along with the hash of columns can be passed to it
1. Clean up and organise the code tests written for it in both Angular and rails.
2. Move the bulk of the code to a directive
3. The selected rows can be accessed from outside the directive ( $scope.selected )
4. Allow custom buttons to be added to the header that interact with the selected rows (  $scope.selected )
5. Standard XLS, CSV, PDF (app/reports/pdf_export.rb) export buttons which run from the currently filtered rows and columns. 
   This code needs to access the list of columns (see the worksheet_export and download_xlsx code in batches_controller.rb)
6. Write angular and rails tests to test all of this functionality
7. Detailed documentation as a markdown text file in within the rails doc directory




#Directive Parameters
- columns: hash of columns. This needs to be accessible to both Rails and Angular
- table: underlying physical table (maybe embed this information in the columns hash ?)
- filterable: boolean which enables the modal filter functionality
- hide_columns: boolean which enables the ability to hide columns, as well as the show all button
- selectable: boolean, which enables the check box
- pagination: boolean, enables the pagination links including page and row counts
- deletable: boolean, enables the delete button
- sortable: sort rows by clicking on header
- export: xls / csv / pdf
- probably also need a way to link the detail of the table to the page header... maybe pass in the batch_id ?




#List of columns in Rails

  FIELDS =    { source:         'Source',
	              status:         'Status',
	              chrom:          'Chromosome',
	              chrom_start:    'Start',
	              chrom_end:      'Stop',
	              gene:           'Gene',
	              cosmic_mut_id:  'COSMIC Id',
                primer_left:    'Left',
	              primer_right:   'Right'}       
                  
List of columns in Angular
--------------------------
    $scope.fields =  [  {key: 'id', value: 'id'},
	                    {key: 'source', value: 'Source'}
		                {key: 'status', value: 'Status'},
		                {key: 'chrom', value: 'Chromosome'},
		                {key: 'chrom_start', value: 'Start'},
		                {key: 'chrom_end', value: 'Stop'},
		                {key: 'gene', value: 'Gene'},
		                {key: 'cosmic_mut_id', value: 'COSMIC Id'},
		                {key: 'primer_left', value: 'Left'},
		                {key: 'primer_right', value: 'Right'} ]       