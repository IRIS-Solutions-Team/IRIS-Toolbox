function [ ...
    hashEquationsAll, ...
    hashEquationsIndividually, ...
    hashEquationsInput, ...
    hashIncidence ...
] = prepareHashEquations(this)
% prepareHashEquations  Prepare anonymous functions for evaluating hash equations
% 
% Backend [IrisToolbox] method
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

%--------------------------------------------------------------------------

%
% Select dynamic hash equations
%
inxHash = this.Equation.InxOfHashEquations;
eqtn = this.Equation.Dynamic(inxHash);
eqtn = cellfun(@vectorize, eqtn, 'UniformOutput', false);
preamble = this.PREAMBLE_DYNAMIC;

%
% Function to evaluate all hash equations at once
%
hashEquationsAll = str2func([preamble, '[', eqtn{:}, ']']);

%
% Functions to evaluate all hash equations individually
%
hashEquationsIndividually = cellfun(@(x) str2func([preamble, x]), eqtn, 'UniformOutput', false);

%
% Individual equtions in their user input forms
%
hashEquationsInput = this.Equation.Input(inxHash);

%
% Incidence of YX across hash equations
%
hashIncidence = selectEquation(this.Incidence.Dynamic, inxHash);
hashIncidence = removeTrailingShifts(hashIncidence);

end%

