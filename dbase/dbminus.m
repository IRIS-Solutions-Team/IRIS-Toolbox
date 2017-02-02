% minus  Remove entries from a database.
%
% Syntax
% =======
%
%     D = D - List
%
% Input arguments
% ================
%
% * `D` [ struct ] - Input database from which some entries will be
% removed.
%
% * `List` [ char | cellstr ] - List of entries that will be removed from
% `D`.
%
% Output arguments
% =================
%
% * `D` [ struct ] - Output database with entries listed in `List` removed
% from it.
%
% Description
% ============
%
% This functino works the same way as the built-in function `rmfield`
% except it does not throw an error when some of the entries listed in
% `List` are not found in `D`.
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.
