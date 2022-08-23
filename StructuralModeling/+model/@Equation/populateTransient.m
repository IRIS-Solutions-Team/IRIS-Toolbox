% populateTransient  Populate transient properties of model.Equation
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function this = populateTransient(this)

numEquations = numel(this.Dynamic);
inxM = this.Type==1;
inxT = this.Type==2;
inxMT = inxM | inxT;
preamble = string(this.PREAMBLE);

this.DynamicFunc = cell(1, numEquations);
for i = find(inxMT)
    eqtn = vectorize(string(this.Dynamic{i}));
    this.DynamicFunc{i} = str2func(preamble + "[" + eqtn + "]");
end

end%

