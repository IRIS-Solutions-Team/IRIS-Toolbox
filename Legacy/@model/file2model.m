function [this, opt] = file2model(this, modelSource, opt, preparserOpt, parserOpt, optimalOpt, varargin)

this.LinearStatus = opt.Linear;
this.GrowthStatus = opt.Growth;


%
% __Run preparser__
%

[ ...
    code, this.FileName, ...
    this.Export, controls, ...
    this.Comment, this.Substitutions ...
] ...
= parser.Preparser.parse( ...
    modelSource, [ ] ...
    , "assigned", opt.Context ...
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
    d.(n) = opt.Context.(n);
end
this.PreparserControl = d;


%
% __Run model parser__
%

the = parser.TheParser('model', this.FileName, code, opt.Context);
[qty, eqn, euc, puc, collector, logSpecs] = parse(the, parserOpt);
opt.Context = the.AssignedDatabank;


%
% Run model-specific postparser
%
this = postparse(this, qty, eqn, logSpecs, euc, puc, collector, opt, optimalOpt, varargin{:});

end%

