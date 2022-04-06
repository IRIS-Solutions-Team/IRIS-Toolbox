
%{
---
title: clear
---


# `clear`

{== Clear all charts from the chartpack but preserve all settings ==}


## Syntax

    clear(ch)


## Input arguments

__`ch`__ [ Chartpack ]
>
> Chartpack object from which all existing charts will be cleared; all
> settings assigned by the user will be preserved.
>


## Description

The `clear` function is useful when you wish to reuse a Chartpack objects
with particular settings for another set of charts.


## Examples

%}

%---8<---

function this = clear(this, varargin)

this.Charts = databank.chartpack.Chart.empty(1, 0);

end%

