---
populate: true
---

# Overview of data management tools


#### [Time series](@Series/index.md)

Time series objects are two- or higher-dimensional arrays whose rows are
referenced by dates.


#### [Databanks](+databank/index.md)

Iris uses the standard Matlab structures (struct objects) as databanks
that can store any types of data.  The `+databank` package provides several
functions to automate and streamline some of the most frequent data
handling tasks.


#### [Dates](@Dater/index.md)

Iris dates are designed to provide maximum convenience for handling dates spaced
at regular intervals throughout a calendar year.


#### [Term structures](@Termer/index.md)

Termers are objects for storing and manipulating data organized along a
term-to-maturity dimension, such as yield curves.


#### [Matrices with named rows and columns](@NamedMatrix/index.md)

Matrices with named rows and columns provide great convenience when working
with analytical descriptions of model properties organized as matrices
(e.g. covariance matrices), with the rows and columns referrring to
particualar model quantities.


#### [Data groupings](@Grouping/index.md)

Data grouping objects are used for aggregating the contributions of shocks
in model simulations,
[`Model/simulate`](../../StructuralModeling/@Model/simulate.md), or
aggregating the contributions of measurement variables in Kalman filtering,
[`Model/kalmanFilter`](../../StructuralModeling/@Model/kalmanFilter.md).


#### [Excel spreadsheet data retrieval](@ExcelSheet/index.md)

The ExcelSheet object gives flexible access to data stored in Excel
spreadsheets, and their retrieval as time series and databanks.



