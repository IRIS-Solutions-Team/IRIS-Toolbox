% minus  Remove entries from a database.
%
% Syntax
% =======
%
%     D = D - list
%
%
% Input arguments
% ================
%
% * `d` [ struct ] - Input database from which some entries will be
% removed.
%
% * `list` [ char | cellstr | rexp ] - List of entries that will be removed from
% `d`; the list can be specified as a regular expression wrapped in a
% `rexp` object.
%
%
% Output arguments
% =================
%
% * `d` [ struct ] - Output database with entries listed in `list` removed
% from it.
%
%
% Description
% ============
%
% This function works the same way as the built-in function `rmfield`
% except it does not throw an error when some of the entries listed in
% `list` are not found in `d`.
%
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

function this = dbminus(this, list)

    if ischar(list)
        list = regexp(list, '\w+', 'match');
    elseif isstruct(list)
        list = fieldnames(list);
    end

    f = reshape(fieldnames(this), 1, []);
    c = reshape(struct2cell(this), 1, []);
    [fNew, ix] = setdiff(f, list, 'stable');
    this = cell2struct(c(ix), cellstr(fNew), 2);

end%

