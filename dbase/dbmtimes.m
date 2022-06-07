function this = dbmtimes(this, list)
% mtimes  Keep only the database entries that are on the list.
%
% Syntax
% =======
%
%     d = d * list
%
%
% Input arguments
% ================
%
% * `d` [ struct ] - Input database.
%
% * `list` [ cellstr ] - List of entries that will be kept in the output
% database.
%
%
% Output arguments
% =================
%
% * `d` [ struct ] - Output database where only the input entries that
% are in the `list` are included.
%
%
% Description
% ============
%
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

pp = inputParser( );
pp.addRequired('d', @isstruct);
pp.addRequired('list', @(x) iscellstr(x) || ischar(x));
pp.parse(this, list);

%--------------------------------------------------------------------------

if ischar(list)
    list = regexp(list, '\w+', 'match');
end

f = fieldnames(this).';
c = struct2cell(this).';
[fNew, ix] = intersect(f, list, 'stable');
this = cell2struct(c(ix), cellstr(fNew), 2);

end%

