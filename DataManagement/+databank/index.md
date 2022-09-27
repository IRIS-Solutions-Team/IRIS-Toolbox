---
populate: true
topic: +databank
---

# Overview of databank package functions

{==
Iris uses the standard Matlab structures (struct objects) as databanks
that can store any types of data.  The `+databank` package provides several
functions to automate and streamline some of the most frequent data
handling tasks.
==}


## Categorical list of functions 


### Creating, converting, importing, and exporting databanks 

Function | Description
---|---
[`databank.toSheet`](toSheet.md) | Save databank of time series to a XLSX or CSV file
[`databank.fromSheet`](fromSheet.md) | Load databank of time series from a XLSX or CSV file
[`databank.fromArray`](fromArray.md) | Create a time series databank from a numeric array
[`databank.toArray`](toArray.md) | Create numeric array from time series data
[`databank.fromCSV`](fromCSV.md) | Create databank by loading CSV file
[`databank.toCSV`](toCSV.md) | Write databank to CSV file
[`databank.withEmpty`](withEmpty.md) | Create databank with empty time series


### Getting and visualizing information about databanks 

Function | Description
---|---
[`databank.fieldNames`](fieldNames.md) | List of databank field names as a row vector of strings
[`databank.list`](list.md) | List databank fields adding date range to time series fields
[`databank.range`](range.md) | Find a range that encompasses the ranges of all or selected databank time series
[`databank.spy`](spy.md) | Visualize availability of databank time series observations


### Processing databanks 

Function | Description
---|---
[`databank.addMissingFields`](addMissingFields.md) | Create fields missing from a list, and assign them a default value
[`databank.apply`](apply.md) | Apply function to a selection of databank fields
[`databank.batch`](batch.md) | Execute batch job within databank
[`databank.clip`](clip.md) | Clip all time series in databank to a new range
[`databank.copy`](copy.md) | Copy fields of source databank to target databank
[`databank.eval`](eval.md) | Evaluate an expression within a databank context
[`databank.filterFields`](filterFields.md) | Get the names of databank fields that pass name or value tests
[`databank.merge`](merge.md) | Merge two or more databanks
[`databank.retrieveColumns`](retrieveColumns.md) | Retrieve selected columns from databank fields


### Creating and manipulating model databanks 

Function | Description
---|---
[`databank.forModel`](forModel.md) | Create model specific databank
[`databank.minusControl`](minusControl.md) | Create simulation-minus-control database
[`databank.plusControl`](plusControl.md) | Create simulation-plus-control database


