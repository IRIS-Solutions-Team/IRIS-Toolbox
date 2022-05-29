function output = datarequest(req, this, inp, range)
% datarequest  Request input data
%
% Backend [IrisToolbox] method
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

%--------------------------------------------------------------------------

retX = contains(req, "x", "IgnoreCase", true);
mustX = contains(req, "x*", "IgnoreCase", true);
retI = contains(req, "i", "IgnoreCase", true);
mustI = contains(req, "i*", "IgnoreCase", true);

X = [ ];
I = [ ];

output = datarequest@BaseVAR(req, this, inp, range);

range = output.Range;

if isempty(inp)
    inp = struct( );
end

sw = struct( );
sw.BaseYear = this.BaseYear;

if retX && ~isempty(this.ExogenousNames)
    sw.Warn.NotFound = mustX;
    sw.Warn.NonTseries = mustX;
    X = db2array(inp, range, this.ExogenousNames, sw);
end

if retI && ~isempty(this.ConditioningNames)
    sw.Warn.NotFound = mustI;
    sw.Warn.NonTseries = mustI;
    I = db2array(inp, range, this.ConditioningNames, sw);
end

% Transpose and return data
if retX
    output.X = permute(X, [2,1,3]);
end
if retI
    output.I = permute(I, [2,1,3]);
end

end%

