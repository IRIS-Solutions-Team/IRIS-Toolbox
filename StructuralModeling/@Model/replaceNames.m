%{
% 
% # `replaceNames` ^^(Model)^^
% 
% {== Replace model names with some other names ==}
% 
% 
% ## Syntax
% 
%     model = replaceNames(model, oldNames, newNames)
% 
% 
% ## Input arguments
% 
% __`model`__ [ Model ]
% > 
% > Model object in which some names (variables, shocks, parameters) will be
% > replaced with new names. 
% > 
% 
% __`oldNames`__ [ string ] 
% > 
% > List of existing model names that will be replace with `newNames`.
% > 
% 
% __`newNames`__ [ string ]
% > 
% > List of new names that will replace the `oldNames` in the `model`. The
% > lenght of the `newNames` list must be the same as `oldNames`. The new
% > names must be such that the entire list of all the model names after
% > replacement has all names unique.
% > 
% 
% ## Output arguments
% 
% __`model`__ [ Model ]
% > 
% > Model object with the `newNames` assigned.
% > 
% 
% 
% ## Description
% 
% Use this function to rename some of the model names (variables, shocks,
% parameters). The replacement affects the names under which model quantities
% are being assigned, read in from input databanks, or written out to output
% databanks in functions like [`Model/simulate`](simulate.md). The internal
% representation of the model variables, shocks and parameters in the model
% equations is independent of their names.
% 
% 
% ## Examples
% 
% ### Run the same univariate model for multiple variables
% 
% Create a model object from the following 
%}
% --8<--


% Type `web Model/replaceNames.md` for help on this function
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function this = replaceNames(this, varargin)
this.Quantity = replaceNames(this.Quantity, varargin{:});
end%

