function d = dbfill(d, with)
% dbfill  Fill all database entries with specified value.
%
% Syntax
% =======
%
%     d = dbfill(d, with)
%
%
% Input arguments
% ================
%
% * `d` [ struct ] - Input database.
%
% * `with` [ any ] - Value with which all existing entries in the input
% database `d` will replaced with.
%
%
% Output arguments
% =================
%
% * `d` [ struct ] - Output database with all entries replaced.
%
%
% Description
% ============
%
%
% Example
% ========
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
% -Copyright (c) 2007-2017 IRIS Solutions Team.

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