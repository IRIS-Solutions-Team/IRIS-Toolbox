---
title: databank.fromCSV
---

# `databank.fromCSV` ^^(+databank)^^

{== Create databank by loading CSV file ==}


## Syntax

    outputDb = databank.fromCSV(fileName, ...)


## TL;DR

    db = databank.fromCSV("data.csv")

    db = databank.fromCSV("data.csv", skipRows=1:5)

    db = databank.fromCSV( ...
        "data.csv" ...
        , dateFormat="yyyy/m/d" ...
        , enforceFrequency=Frequency.QUARTERY ...
    )


## Input Arguments 


__`fileName`__ [ string ] 
> 
> Name of the Input CSV data file or a cell array of CSV file names that
> will be combined.
> 

## Output Arguments 


__`outputDb`__ [ struct | Dictionary ]
> 
> Database created from the input CSV file(s).
> 

## Options 


__`AddToDatabank`__ [ struct | Dictionary ]
> 
> Add the data loaded from the input file to an existing databank (struct
> or Dictionary); the format (Matlab class) of `AddToDatabank=` must comply
> with option `OutputType=`.
> 

__`Case=""`__ [ `"lower"` | `"upper"` | `""` ] 
> 
> Change case of variable names.
> 

__`CommentsRow=["Comment", "Comments"]`__ [ string ] 
> 
> Label at the start of row that will be used to create comments in time
> series.
> 

__`Continuous=false`__ [ false | `"descending"` | `"ascending"` ]
> 
> Indicate that dates are a continuous range, either acending or
> descending.
> 

__`DateFormat="YYYYFP"`__ [ string ] 
> 
> Format of dates in first column.
> 

__`Delimiter=","`__ [ string ] 
> 
> Delimiter separating the individual values (cells) in the CSV file; if
> different from a comma, all occurences of the delimiter will replaced
> with commas -- note that this will also affect text in comments.
> 

__`FirstDateOnly=false`__ [ `true` | `false` ] 
> 
> Read and parse only the first date string, and fill in the remaining
> dates assuming a range of consecutive dates.
> 

__`EnforceFrequency=false`__ [ Frequency | `false` ]
> 
> Advise frequency of dates; if empty, frequency will be attempted to be automatically
> recognized from the date string (only possible if the date format
> contains the frequency letter).
> 

__`NamesHeader=["", "Variables", "Time"]`__ [ string | numeric ] 
> 
> String, or a vector of strings, that is at the beginning
> (in the first cell) of the row with variable names, or the line number at
> which the row with variable names appears (first row is numbered 1).
> 

__`NamesFunc=[ ]`__ [ cell | function_handle | empty ] 
> 
> Function used to change or transform the variable names. If a cell array
> of function handles, each function will be applied in the given order.
> 

__`NaN="NaN"`__ [ string ] 
> 
> String representing missing observations (case insensitive).
> 

__`OutputType="struct"`__ [ `"struct"` | `"Dictionary"` ]
> 
> Format (Matlab class) of the output databank.
> 

__`Postprocess=[]`__ [ function_handle | empty ]
> 
> Apply this function to all fields (regardless of the type/class of the
> data) created within this run of `databank.fromCSV`.
> 

__`Preprocess=[ ]`__ [ function_handle | cell | empty ] 
> 
> Apply this function, or cell array of functions, to the raw text file
> before parsing the data.
> 

__`Select=@all`__ [ `@all` | string | empty ] 
> 
> Only databank entries included on this list will be read in and returned
> in the output databank `outputDb`; entries not on this list will be
> discarded; `@all` means all entries found in the CSV file will be
> included in the `outputDb`.
> 

__`SkipRows=[ ]`__ [ char | string | numeric | empty ] 
> 
> Skip rows whose first cell matches the string or strings (regular
> expressions); or, skip a vector of row numbers.
> 

__`DatabankUserData=Inf`__ [ string | `Inf` ] 
> 
> Field name under which the databank-wide user data loaded from the CSV
> file (if they exist) will be stored in the output databank; `Inf` means
> the field name will be read from the CSV file (and will be thus identical
> to the originally saved databank).
> 

__`UserDataField="."`__ [ string ] 
> 
> A leading character denoting user data fields for individual time series;
> if empty, no user data fields will be read in and created.
> 

__`UserDataFieldList=[]`__ [ string | numeric | empty ] 
> 
> List of row headers, or vector of row numbers, that will be included as
> user data in each time series.
> 

## Description 

Use the `"EnforeFrequency="` option whenever there is ambiguity in intepreting
the date strings, and IRIS is not able to determine the frequency
correctly (see Example).


### Structure of CSV Data Files

The minimalist structure of a CSV data file has a leading row with
variables names, a leading column with dates in the basic IRIS format, 
and individual columns with numeric data:

    |         |       Y |       P |
    |---------|---------|---------|--
    |  2010Q1 |       1 |      10 |
    |  2010Q2 |       2 |      20 |
    |         |         |         |

You can add a comment row (must be placed before the data part, and start
with a label "Comment" in the first cell) that will also be read in and
assigned as comments to the individual Series objects created in the
output databank.

    |         |       Y |       P |
    |---------|---------|---------|--
    | Comment |  Output |  Prices |
    |  2010Q1 |       1 |      10 |
    |  2010Q2 |       2 |      20 |
    |         |         |         |

You can use a different label in the first cell to denote a comment row;
in that case you need to set the option `CommentsRow=` accordingly.

All CSV rows whose names start with a character specified in the option
`UserDataField=` (a dot by default) will be added to output Series
objects as fields of their user data.

    |         |       Y |       P |
    |---------|---------|---------|--
    | Comment |  Output |  Prices |
    | .Source |   Stat  |  IMFIFS |
    | .Update | 17Feb11 | 01Feb11 |
    | .Units  | Bil USD |  2010=1 |
    |  2010Q1 |       1 |      10 |
    |  2010Q2 |       2 |      20 |
    |         |         |         |


## Example 


Typical example of using the `EnforeFrequency=` option is a quarterly
databank with dates represented by the corresponding months, such as a
sequence 2000-01-01, 2000-04-01, 2000-07-01, 2000-10-01, etc. In this
case, you can use the following options:

    d = databank.fromCSV( ...
        "MyDataFile.csv" ...
        , "dateFormat=", "YYYY-MM-01" ...
        , "enforeFrequency=", Frequency.QUARTERLY ...
    );



-[IrisToolbox] for Macroeconomic Modeling
-Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

