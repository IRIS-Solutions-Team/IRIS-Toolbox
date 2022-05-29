
%{
---
title: LinearSystem.fromModel
---

# `LinearSystem.fromModel`

{== Prepare LinearSystem object from Model object ==}


## Syntax

    ls = LinearSystem.fromModel(model, filterRange, override, multiply, ___)


## Input arguments

__`model`__ [ Model ]
>
> Model from which a time-varying linear system, `ls`, will be created for
> the time-varying parameters and stdcorrs.
> 

__`filterRange`__ [ Dater ]
> 
> Date range for which the time-varying linear system `ls` will be created.
> 

__`override`__ [ struct | empty ]
> 
> Databank with time-varying parameters and stdcorrs.
> 

__`multiply`__ [ struct | empty ]
>
> Databank with time-varying mutlipliers that will be applied to stdcorrs.
> 

## Output arguments

__`ls`__ [ LinearSystem ]
>
> A time-varying linear system object that can be used to run a time-varying
> Kalman filter.
>


## Options

__`Variant=1`__ [ numeric ]
>
> Select this parameter variant if the input `model` has multiple variants.
>

__`BreakUnlessTimeVarying=false`__ [ `true` | `false` ]
>
> Return prematurely with `ls = []` if no time-varying parameters or
> stdcorrs are specified in `override` or `multiply`
>

## Description


## Examples

%}


%---8<---


% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function varargout = fromModel(model, varargin)

[varargout{1:nargout}] = prepareLinearSystem(model, varargin{:});

end%

