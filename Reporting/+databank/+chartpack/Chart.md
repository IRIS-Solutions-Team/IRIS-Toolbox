# databank.Chartpack

{== Create a new Chart object for plotting databank fields ==}


## Syntax

    ch = databank.Chart()

## Output Arguments

__`ch`__ [ databank.Chart ]
>
> New empty databank.Chart object
>

## Customizable properties

After creating a new Chart object, set the following properties to customize the way the charts are produced and styled: 

### Customize settings

__`ParentChartpack=[]`__ [ struct ]
>
>  Set parent chartpack.
>

__`InputString=`__ [ string ]
>
>  Set input string.
>

__`Expression=`__ [ string ]
>
>  Set expression.
>

__`Data=[]`__ [ struct ]
>
>  Set data to be used.
>

__`Expansion=@parent`__ [ `@parent` ]
>
>  Set expansion based on the parent.
>

__`ApplyTransform=true`__ [ `true*` | `false` ]
>
>  Flag setting the transformation.
>

__`Transform=@parent`__ [ `@parent` ]
>
>  Setting transformation based on the parent.
>

__`PlotSettings=cell.empty(1, 0)`__ [ `@parent` ]
>
>  Set plot settings.
>

__`PageBreak=false`__ [ `true` | `false*` ]
>
>  Flag setting pagebreaks.
>

__`PageBreak=false`__ [ `true` | `false*` ]
>
>  Flag setting empty plots.
>

## Description 



## Examples

```matlab
```
