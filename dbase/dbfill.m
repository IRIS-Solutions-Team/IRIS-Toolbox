function d = dbfill(d, with)
% dbfill  Fill all database entries with specified value.
%
% __Syntax__
%
%     D = dbfill(D, With)
%
%
% __Input Arguments__
%
% * `D` [ struct ] - Input database.
%
% * `With` [ any ] - Value with which all existing entries in the input
% database `D` will replaced with.
%
%
% __Output Arguments__
%
% * `D` [ struct ] - Output database with all entries replaced.
%
%
% __Description__
%
%
% __Example__
%
%     d = struct('a', 1, 'b', tseries(1:10, @rand))
%     d = 
%         a: 1
%         b: [10x1 tseries]
%     dbfill(d, NaN)
%     ans = 
%         a: NaN
%         b: NaN
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%--------------------------------------------------------------------------


lsf = fieldnames(d);
nf = length(lsf);
for i = 1 : nf
    name = lsf{i};
    if isstruct(d.(name))
        d.(name) = dbnan(d.(name));
        continue
    end
    d.(name) = with;
end

end
