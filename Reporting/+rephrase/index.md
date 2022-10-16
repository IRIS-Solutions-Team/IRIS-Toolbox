---
topic: +rephrase
populate: true
---

# Overview of the HTML reporting package

{==
The reporting package, `+rephrase`, uses HTML/CSS/Javascript to build
interactive reports consisting of charts, tables, snippets of code, text,
structured in sections or pages.
==}
 

## Structure of reports

=== "Report"

    The `rephrase.Report` is the top-level container for all report
    elements. The `rephrase.Report` may include the following:

    Containers:

    * `rephrase.Section`
    * `rephrase.Grid`
    * `rephrase.Pager`
    * `rephrase.SeriesChart`
    * `rephrase.CurveChart`
    * `rephrase.Table`


    Terminal elements:

    * `rephrase.Matrix`
    * `rephrase.Text`
    * `rephrase.Pagebreak`


=== "Section"

    The `rephrase.Section` is a report structuring object, dividing it into
    logical parts referred to in the Table of Contents. The
    `rephrase.Section` may include the following:

    Containers:

    * `rephrase.Section`
    * `rephrase.Grid`
    * `rephrase.Pager`
    * `rephrase.SeriesChart`
    * `rephrase.CurveChart`
    * `rephrase.Table`


    Terminal elements:

    * `rephrase.Matrix`
    * `rephrase.Text`
    * `rephrase.Pagebreak`



=== "Grid"

    The `rephrase.Grid` is a container laying out the elements in an N-by-M
    grid. The `rephrase.Grid` may include the following:

    Containers:

    * `rephrase.SeriesChart`
    * `rephrase.CurveChart`
    * `rephrase.Table`

    Terminal elements:

    * `rephrase.Matrix`


=== "Pager"

    The `rephrase.Pager` creates an interactive switch with multiple pages.
    The `rephrase.Pager` may include the following:

    Containers:

    * `rephrase.Section`
    * `rephrase.Grid`
    * `rephrase.Pager`
    * `rephrase.SeriesChart`
    * `rephrase.CurveChart`
    * `rephrase.Table`


    Terminal elements:

    * `rephrase.Matrix`
    * `rephrase.Text`


=== "SeriesChart"

    The `rephrase.SeriesChart` is a time series chart, possibly with
    multiple series included. The `rephrase.SeriesChart` may include the
    following:

    Terminal elements:

    * `rephrase.Series`


=== "CurveChart"

    The `rephrase.CurveChart` is a term structure chart designed to show
    yiled curves and other data along a term-to-maturity dimension. The
    `rephrase.CurveChart` may include the following:

    Terminal elements:

    * `rephrase.Curve`


=== "Table"

    The `rephrase.Table` is a time series table. The `rephrase.Table` may
    include the following:

    Terminal elements:

    * `rephrase.DiffSeries`
    * `rephrase.Heading`
    * `rephrase.Series`



## Categorical list of objects


### Constructing new reports

Function | Description
---|---
[`rephrase.Report`](Report.md) | Create a Report object for rephrase reports


### Structuring the report

Function | Description
---|---
[`rephrase.Grid`](Grid.md) | Create a Grids object for rephrase reports
[`rephrase.Pagebreak`](Pagebreak.md) | Create a Pagebreak object for rephrase reports
[`rephrase.Pager`](Pager.md) | Create a Text object for rephrase reports
[`rephrase.Section`](Section.md) | Create a Section object for rephrase reports


### Creating time series charts

Function | Description
---|---
[`rephrase.SeriesChart`](SeriesChart.md) | Create a SeriesChart object for rephrase reports
[`rephrase.Series`](Series.md) | Create a Series object for rephrase reports
[`rephrase.Bands`](Bands.md) | Create a Bands object for rephrase reports
[`rephrase.Highlight`](Highlight.md) | Create a Highlight object for rephrase reports


### Creating term structure charts

Function | Description
---|---
[`rephrase.CurveChart`](CurveChart.md) | Create a CurveChart object for rephrase reports
[`rephrase.Curve`](Curve.md) | Create a Curve object for rephrase reports
[`rephrase.Highlight`](Highlight.md) | Create a Highlight object for rephrase reports


### Creating time series tables

Function | Description
---|---
[`rephrase.Table`](Table.md) | Create a Table object for rephrase reports
[`rephrase.Series`](Series.md) | Create a Series object for rephrase reports
[`rephrase.DiffSeries`](DiffSeries.md) | Create a DiffSeries object for rephrase reports


### Creating data matrices

Function | Description
---|---
[`rephrase.Matrix`](Matrix.md) | Create a Matrix object for rephrase reports


### Creating text elements

Function | Description
---|---
[`rephrase.Text`](Text.md) | Create a Text object for rephrase reports


