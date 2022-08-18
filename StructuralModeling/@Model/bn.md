
---
title: bn
---

{== Beveridge-Nelson trends ==}


## Syntax

    Outp = bn(SolvedModel, InputData, Range, ...)


## Input Arguments

`SolvedModel` [ model ] 
>
>Solved model object.
>

`InputData` [ struct | cell ] 
>
>Input data on which the BN trends will
>be computed.
>

`Range` [ numeric | char ] 
>
>Date range on which the BN trends will be
>computed.
>

## Output Arguments 

`Outp` [ struct | cell ] 
>
>Output data with the BN trends.
>

## Options

`Deviation=false` [ `true` | `false` ] 
>
>Input and output data are
>deviations from steady-state paths.
>

`DTrends=@auto` [ `@auto` | `true` | `false` ] 
>
>Measurement variables
>in input and output data include deterministic trends specified in
>[`!measurement-trends`](irislang/dtrends) equations.
>

## Description 
>
>The BN decomposition is accurate only if the input data have been
>generated using unanticipated shocks.
>

## Examples


