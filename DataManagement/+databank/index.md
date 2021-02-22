# Databank Functions

IrisT uses the standard Matlab structures (struct objects) as databanks
that can store any types of data.  The `+databank` package provides several
functions to automate and streamline some of the most frequent data
handling tasks.


## Categorical List of Functions

### Creating, Converting, Importing, and Exporting Databanks

| Function      | Description       |
|---            |---                |
| [`databank.fromCSV`](fromCSV.md)                      | {{ databank._fromCSV }} |
| [`databank.toCSV`](toCSV.md)                          | {{ databank._toCSV }} |
| [`databank.withEmpty`](withEmpty.md)                  | {{ databank._withEmpty }} |


### Getting Information about Databanks

| Function      | Description       |
|---            |---                |
| [`databank.fieldNames`](fieldNames.md)                | {{ databank._fieldNames }} |
| [`databank.list`](list.md)                            | {{ databank._list }} |


### Processing Databanks

| Function      | Description       |
|---            |---                |
| [`databank.apply`](apply.md)                          | {{ databank._apply }} |
| [`databank.clip`](clip.md)                            | {{ databank._clip }} |
| [`databank.copy`](copy.md)                            | {{ databank._copy }} |
| [`databank.eval`](eval.md)                            | {{ databank._eval }} |
| [`databank.filterFields`](filterFields.md)            | {{ databank._filterFields }} |
| [`databank.merge`](merge.md)                          | {{ databank._merge }} |
| [`databank.retrieveColumns`](retrieveColumns.md)      | {{ databank._retrieveColumns }} |

