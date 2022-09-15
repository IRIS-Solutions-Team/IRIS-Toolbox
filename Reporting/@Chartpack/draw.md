---
title: draw
---

# `draw`

{== Render charts defined in Chartpack ==}


## Syntax

    info = draw(ch, inputDb)


## Input arguments

__`ch`__ [ Chartpack ]
> 
> Chartpack object whose charts will be rendered on the screen.
> 

__`inputDb`__ [ struct | Dictionary ]
> 
> Input databank within which the expressions defining the charts will be
> evaluated, and the results plotted.
> 

## Output arguments

__`info`__ [ struct ]
> 
> Output information structure with the following fields:
> 
> * `.FigureHandles` - handles to all figure objects created;
> 
> * `.AxesHandles` - cell array of handles to all axes objects created,
>   grouped by figures;
> 
> * `.PlotHandles` - cell array of cell arrays of handles to all objects
>   plotted within axes, grouped by figures and by axes;
> 
> * `.TitleHandles` - cell array of handles to all title objects created,
>   grouped by figures;
> 
> * `.SubtitleHandles` - cell array of handles to all subtitle objects
>   created, grouped by figures;
> 

## Description


## Examples

