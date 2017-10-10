function [this, opt] = file2model(this, fileName, opt, optimalOpt)
% file2model  Translate model file to model object properties.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

% Run the parser.
[code, this.FileName, this.Export, ctrlParameters, this.Comment] = ...
    parser.Preparser.parse(fileName, [ ], opt.Assign, opt.saveas, '');

% Export files; they must be available before we run the postparser because
% we check for syntax errors by evaluating model equations which may refer
% to exportable functions.
export(this);

% Create database of parameters occurring in control expressions.
d = struct( );
for i = 1 : length(ctrlParameters)
    name = ctrlParameters{i};
    d.(name) = opt.Assign.(name);
end
this.PreparserControl = d;

% Run the main model-specific parser.
the = parser.TheParser('model', this.FileName, code, opt.Assign);
[quantity, equation, euc, puc] = parse(the, opt);
opt.Assign = the.AssignedDatabank;

% Run model-specific postparser.
this = postparse(this, quantity, equation, euc, puc, opt, optimalOpt);

end
