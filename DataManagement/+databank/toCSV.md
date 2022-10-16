---
title: databank.toCSV
---

# `databank.toCSV` ^^(+databank)^^

{== Write databank to CSV file ==}


## Syntax

    fieldsSaved = databank.toCSV(inputDb, fileName, dates, ...)


## Input Arguments


__`inputDatabank`__ [ struct | Dictionary ]
> 
> Input databank whose time series and numeric entries will be serialized
> to a character vector.
> 

__`fileName`__ [ string ]
> 
> Name of a CSV file to which the databank will be saved.
> 

__`dates`__ [ Dater | `Inf` ] 
> 
> Dates or date range on which the time series will be saved; `Inf` means
> a date range from the earliest date found in the `inputDatabank` to the
> latest date.
> 

## Output Arguments

__`fieldsSaved`__ [ string ]
> 
> List of databank fields that have been written to the output file 
> `fileName`.
> 


## Options

__`NamesHeader="Variables->"`__ [ string ] 
> 
> String that will be put in the top-left corncer (cell A1).
> 

__`Class=true`__ [ `true` | `false` ] 
> 
> Include a row with class and size specifications.
> 

__`Comments=true`__ [ `true` | `false` ] 
> 
> Include a row with comments for time series.
> 

__`Decimals=[ ]`__ [ numeric ] 
> 
> Number of decimals up to which the data will be saved; if empty the
> numeric format is taken from the option `Format`.
> 

__`Format="%.8e"`__ [ string ] 
> 
> Numeric format that will be used to represent the data, see `sprintf` for
> details on formatting, The format must start with a `"%"`, and must not
> include identifiers specifying order of processing, i.e. the `"$"` signs,
> or left-justify flags, the `"-"` signs.
> 

__`FreqLetters=["Y", "H", "Q", "M", "W"]`__ [ string ] 
> 
> Vector of five letters to represent the five possible date frequencies except daily
> and integer (annual, semi-annual, quarterly, monthly, weekly).
> 

__`MatchFreq=false`__ [ `true` | `false` ] 
> 
> Save only those time series whose date frequencies match the input vector
> of `dates`.
> 

__`NaN="NaN"`__ [ string ] 
> 
> String to represent `NaN` values.
> 

__`TargetNames=[]`__ [ empty | function ]
> 
> Function transforming the databank field names to the names under which
> the data are saved in the CSV file; `TargetNames=[]` means no
> transformation.
> 

__`UserDataFields=[]`__ [ empty | string ]
> 
> List of user data fields that will be extracted from each time series
> object, and saved to the CSV file; the name of the row where each user
> data field is saved is `.xxx` where `xxx` is the name of the user data
> field.
> 

## Description


## Example

Create a simple database with two time series.

    D = struct( );
    D.x = Series(qq(2010, 1):qq(2010, 4), @rand);
    D.y = Series(qq(2010, 1):qq(2010, 4), @rand);

Add your own description of the database, e.g.

    D.UserData = {'My database', datestr(now( ))};

Save the database as CSV using `databank.toCSV`, 

    databank.toCSV(D, 'mydatabase.csv');

When you later load the database, 

    D = databank.fromCSV('mydatabase.csv')

    D = 

       UserData: {'My database'  '23-Sep-2011 14:10:17'}
              x: [4x1 Series]
              y: [4x1 Series]

the database will preserve the `'UserData''` field.


## Example

```matlab
D = struct( );
D.x = Series(qq(2010, 1):qq(2010, 4), @rand);
D.y = Series(qq(2010, 1):qq(2010, 4), @rand);
databank.toCSV(D, 'datafile.csv', Inf)
```

