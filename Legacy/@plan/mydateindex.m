function [X,OutOfRng] = mydateindex(This,Dates)
% mydateindex [Not a public function] Check user dates against plan range.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%--------------------------------------------------------------------------

nPer = round(This.End - This.Start + 1);

if isequal(Dates,@all)
    X = 1 : nPer;
    OutOfRng = false(1,0);
    return
end

X = round(Dates - This.Start + 1);
ixOutOfRng = X < 1 | X > nPer;
OutOfRng = Dates(ixOutOfRng);
X(ixOutOfRng) = NaN;

end
