---
title: Pagebreak
---

# `Pagebreak`

{== Creates pagebreak object for rephrase reports ==}


## Syntax 

    pagebreak = rephrase.Pagebreak(varargin)


## Input arguments 

__`xxx`__ [ xxx | ___ ]
> 
> Description
> 

## Output arguments 

__`yyy`__ [ yyy | ___ ]
> 
> Description
> 

## Options 

__`zzz=default`__ [ zzz | ___ ]
> 
> Description
> 

## Description 

The function `+rephrase/Pagebreak` returns the Pagebreak. The object itself needs to be passed to the parent rephrase object such as `+rephrase/Report`. The function uses no arguements or options and inserts a pagebreak into the report. This however is only used when exporting PDFs.

## Examples

```matlab

pagebreak = rephrase.Pagebreak();

```
