function output = datarequest(req, this, inp, range)
% datarequest  Request input data
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

%--------------------------------------------------------------------------

retX = ~isempty( strfind(req, 'x') );
mustX = ~isempty( strfind(req, 'x*') );
retI = ~isempty( strfind(req, 'i') );
mustI = ~isempty( strfind(req, 'i*') );

X = [ ];
I = [ ];

output = datarequest@varobj(req, this, inp, range);

range = output.Range;

if isempty(inp)
    inp = struct( );
end

sw = struct( );
sw.BaseYear = this.BaseYear;

if retX && ~isempty(this.NamesExogenous)
    sw.Warn.NotFound = mustX;
    sw.Warn.NonTseries = mustX;
    X = db2array(inp, range, this.NamesExogenous, sw);
end

if retI && ~isempty(this.NamesConditioning)
    sw.Warn.NotFound = mustI;
    sw.Warn.NonTseries = mustI;
    I = db2array(inp, range, this.NamesConditioning, sw);
end

% Transpose and return data
if retX
    output.X = permute(X, [2,1,3]);
end
if retI
    output.I = permute(I, [2,1,3]);
end

end%

