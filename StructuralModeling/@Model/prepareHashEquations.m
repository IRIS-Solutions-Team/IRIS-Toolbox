function [ ...
    hashEquationsAll, hashEquationsIndividually, ...
    hashEquationsInput, hashIncidence ...
] = prepareHashEquations(this)

%
% Select dynamic hash equations
%
inxHash = this.Equation.InxHashEquations;
eqtn = this.Equation.Dynamic(inxHash);
eqtn = cellfun(@vectorize, eqtn, 'UniformOutput', false);
preamble = model.Equation.PREAMBLE;

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

