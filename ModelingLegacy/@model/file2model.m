function [this, opt] = file2model(this, modelFile, opt, parserOpt, optimalOpt)
% file2model  Translate model file to model object properties
%
% Backend [IrisToolbox] function
% No help provided

% -[IrisToolbox] Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

%--------------------------------------------------------------------------

%
% Run the preparser
%
[ ...
    code, this.FileName, ...
    this.Export, ctrlParameters, ...
    this.Comment, this.Substitutions ...
] = parser.Preparser.parse( ...
    modelFile, [ ], ...
    'AngleBrackets=', true, ...
    'Assigned=', opt.Assign, ...
    'SaveAs=', opt.SavePreparsed ...
);

%
% Export files; they must be available before we run the postparser because
% we check for syntax errors by evaluating model equations which may refer
% to exportable functions
%
export(this);

%
% Create database of parameters occurring in control expressions
%
d = struct( );
for i = 1 : length(ctrlParameters)
    name = ctrlParameters{i};
    d.(name) = opt.Assign.(name);
end
this.PreparserControl = d;

%
% Run the main model-specific parser
%
the = parser.TheParser('model', this.FileName, code, opt.Assign);
[quantity, equation, euc, puc, collector] = parse(the, parserOpt);
opt.Assign = the.AssignedDatabank;

%
% Run model-specific postparser
%
this = postparse(this, quantity, equation, euc, puc, collector, opt, optimalOpt);

end%

