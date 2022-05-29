% datarequest  Request input data
%
% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 IRIS Solutions Team

% Req: y, y*, e, e*
% Outp.Range
% Outp.Y
% Outp.E
% Outp.Format


function outp = datarequest(request, this, inputDb, range)

retY = contains(request, "y");
mustY = contains(request, "y*");
retE = contains(request, "e");
mustE = contains(request, "e*");

Y = [ ];
E = [ ];

range = double(range);
isInfRange = any(isinf(range));
if isInfRange
    range = Inf;
else
    if ~isempty(range)
        range = range(1) : range(end);
    end
end

if isInfRange
    range = databank.range( ...
        inputDb ...
        , "sourceNames", textual.stringify(this.EndogenousNames) ...
        , "multiFrequencies", false ...
    );
end

sw = struct( );
sw.BaseYear = this.BaseYear;

if retY
    sw.Warn.NotFound = mustY;
    sw.Warn.NonTseries = mustY;
    Y = db2array(inputDb, range, this.EndogenousNames, sw);
end

if retE
    sw.Warn.NotFound = mustE;
    sw.Warn.NonTseries = mustE;
    E = db2array(inputDb, range, this.ResidualNames, sw);
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

