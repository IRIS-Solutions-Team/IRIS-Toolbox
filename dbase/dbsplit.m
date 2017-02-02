function varargout = dbsplit(D,varargin)
% dbsplit  Split database into mutliple databases.
%
% Syntax
% =======
%
%     [D1,D2,...,DN,D] = dbsplit(D,Rule1,Rule2,...,RuleN,...)
%
% Input arguments
% ================
%
% * `D` [ struct ] - Input database that will be split.
%
% * `Rule1`, `Rule2`, ..., `RuleN` [ cellstr ] - Each rule is a 1-by-2 cell
% array, `{testRex,newName}`, where `testRex` is a test `regexp` pattern to
% select entries from the input database, `D`, for inclusion in the K-th
% output database, and `newName` is a new name pattern that will be used to
% name the entry in the output database.
%
% Output arguments
% =================
%
% * `D1`, `D2`, ..., `DN` [ struct ] - Output databases.
%
% * `D` [ struct ] - Input database with remaining fields (if `'discard='
% true`) or the original input database (if `'discard=' false`).
%
% Options
% ========
%
% * `'discard='` [ *`true`* | *`false`* ] - Discard input database entries
% when they are included in an output database, and do not re-use them in
% other output databases; if `false`, an input database entry can occur in
% more than one output databases.
%
% Description
% ============
%
% The test regexp pattern and the new name pattern in each rule work as an
% expression-replace pair in `regexprep` -- see `doc regexprep`. The test
% patterns is a regexp string where you can capture tokens `(...)` for use
% in the new name pattern, `$1`, `$2`, etc.
%
% Example
% ========
%
% The database `D` contains time series for two regions, `US` and `EU`:
%
%     D = 
%         US_GDP: [40x1 tseries]
%         US_CPI: [40x1 tseries]
%         EU_GDP: [40x1 tseries]
%         EU_CPI: [40x1 tseries]
%
% We split the database into two separate databases, one with `US` data
% only, the other with `EU` data only. We also strip the time series names
% of the country prefixes in the new databases.
%
%     [US,EU,DD[ ] = dbsplit(D,{'^US_(.*)','$1'},{'^EU_(.*)','$1'})
% 
%     US = 
%         GDP: [40x1 tseries]
%         CPI: [40x1 tseries]
%     EU = 
%         CPI: [40x1 tseries]
%         GDP: [40x1 tseries]
%     DD = 
%     struct with no fields.
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

lastRule = min([length(varargin),find(cellfun(@ischar,varargin),1)-1]);
rule = varargin(1:lastRule);
varargin(1:lastRule) = [ ];
opt = passvalopt('dbase.dbsplit',varargin{:});

%--------------------------------------------------------------------------

dList = fieldnames(D);
nOut = length(rule);
varargout = cell(1,nOut);
for iOut = 1 : nOut
    testPattern = rule{iOut}{1};
    newName = rule{iOut}{2};
    match = regexp(dList,testPattern,'match','once');
    match = match(~cellfun(@isempty,match));
    newName = regexprep(match,testPattern,newName,'once');
    x = struct( );
    for j = 1 : length(match)
        x.(newName{j}) = D.(match{j});
    end
    varargout{iOut} = x;
    if opt.discard
        dList = setdiff(dList,match);
    end
end

if nargout > nOut
    if opt.discard
        D = mtimes(D,dList);
    end
    varargout{end+1} = D;
end

end