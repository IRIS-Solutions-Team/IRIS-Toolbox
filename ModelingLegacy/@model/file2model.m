% file2model  Translate model file to model object properties
%
% Backend [IrisToolbox] method
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

function [this, opt] = file2model(this, modelFile, opt, preparserOpt, parserOpt, optimalOpt)

%
% __Run preparser__
%

[ ...
    code, this.FileName, ...
    this.Export, controls, ...
    this.Comment, this.Substitutions ...
] ...
= parser.Preparser.parse( ...
    modelFile, [ ] ...
    , "assigned", opt.Assign ...
    , "saveAs", opt.SavePreparsed ...
    , preparserOpt{:} ...
);

% Export files; they must be available before we run the postparser because
% we check for syntax errors by evaluating model equations which may refer
% to exportable functions

export(this);


% Create database of parameters occurring in control expressions

d = struct( );
for n = reshape(string(controls), 1, [ ])
    d.(n) = opt.Assign.(n);
end
this.PreparserControl = d;


%
% __Run model parser__
%

the = parser.TheParser('model', this.FileName, code, opt.Assign);
[quantity, equation, euc, puc, collector, log] = parse(the, parserOpt);
opt.Assign = the.AssignedDatabank;

%
% Run model-specific postparser
%
this = postparse(this, quantity, equation, log, euc, puc, collector, opt, optimalOpt);

end%

