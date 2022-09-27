---
title: rephrase.Report
---

# `rephrase.Report` ^^(+rephrase)^^

{== Create a Report object for rephrase reports ==}


## Syntax 

    output = rephrase.Report(title, varargin)


## Input arguments 

__`title`__ [ string ]
> 
> Report name.
> 

## Output arguments 

__`output`__ [ Report ]
> 
> Report type object with the assigned arguements to be
> passed into the rephrase objects.
> 

## Options 

__`Subtitle=`__ [ string ]
> 
> Subtitle text.
> 

__`Footer=`__ [ string ]
> 
> Footer text.
> 

__`InteractiveCharts=true`__ [ `true*` | `false` ]
> 
> Flag which enables the graph interaction by default and can
> be set to false.
> 

__`TableOfContents=false`__ [ `true` | `false*` ]
> 
> Flag disables the table of contents generation by default and
> can be set to false.
> 

__`TableOfContentsDepth=1`__ [ numeric ]
> 
> The options sets the table of contents depth.
> 

__`Logo=false`__ [ `true` | `false*` ]
> 
> Flag disables the logo by default and
> can be set to false.
> 

## Possible children

`+rephrase/Grid`
`+rephrase/Table`
`+rephrase/Chart`
`+rephrase/SeriesChart`
`+rephrase/CurveChart`
`+rephrase/Text`
`+rephrase/Pagebreak`
`+rephrase/Matrix`
`+rephrase/Pager`
`+rephrase/Section`

## Description 

The function `+rephrase/Report` returns the Report object based on the input arguments and options set by the user.

## Examples

```matlab

report = rephrase.Report( ...
    "Title" ...
    , "Subtitle", "Subtitle" ...
    , "Footer", "See end pages for further important disclaimer." ...
    , "InteractiveCharts", true ...
);

```
