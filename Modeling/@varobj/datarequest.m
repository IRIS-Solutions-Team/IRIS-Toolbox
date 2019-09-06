function outp = datarequest(req, this, inp, range)
% datarequest  Request input data
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

% Req: y, y*, e, e*
% Outp.Range
% Outp.Y
% Outp.E
% Outp.Format

%--------------------------------------------------------------------------

retY = ~isempty( strfind(req, 'y') );
mustY = ~isempty( strfind(req, 'y*') );
retE = ~isempty( strfind(req, 'e') );
mustE = ~isempty( strfind(req, 'e*') );

Y = [ ];
E = [ ];

range = double(range);
if any(isinf(range))
    range = Inf;
    isInfRange = true;
else
    if ~isempty(range)
        range = range(1) : range(end);
    end
    isInfRange = false;
end

if isInfRange
    range = dbrange(inp, this.NamesEndogenous);
end

sw = struct( );
sw.BaseYear = this.BaseYear;

if retY
    sw.Warn.NotFound = mustY;
    sw.Warn.NonTseries = mustY;
    Y = db2array(inp, range, this.NamesEndogenous, sw);
end

if retE
    sw.Warn.NotFound = mustE;
    sw.Warn.NonTseries = mustE;
    E = db2array(inp, range, this.NamesErrors, sw);
end

outp.Range = range;

% Transpose and return data
if retY
    outp.Y = permute(Y, [2, 1, 3]);
end
if retE
    outp.E = permute(E, [2, 1, 3]);
end

end%

