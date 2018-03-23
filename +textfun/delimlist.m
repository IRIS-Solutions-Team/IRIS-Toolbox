function s = delimlist(c, varargin)
% cslist  Convert cellstr to delimited list.
%
% Syntax
% =======
%
%     S = textfun.delimlist(C,...)
%
%
% Input arguments
% ================
%
% * `C` [ cellstr ] - Cell array of strings that will be converted to a
% comma-separated list.
%
%
% Output arguments
% =================
%
% * `S` [ char ] - Text string with comma-separated list.
%
%
% Options
% ========
%
% * `'lead='` [ char | numeric |*empty* ] - Leading string at the beginning
% of each line; a numeric value indicates the number of blank spaces.
%
% * `'delimiter='` [ char | *`', '`* ] - Delimiter between tokens.
%
% * `'trail='` [ char | numeric | *empty* ] - Trailing string at the end of
% each line; a numeric value indicates the number of blank spaces.
%
% * `'quote='` [ *`'none'`* | `'single'` | `'double'` ] - Enclose listed
% tokens in quotes.
%
% * `'wrap='` [ numeric | *`Inf`* ] - Insert line break after reaching the
% specified column.
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
% -Copyright (c) 2007-2018 IRIS Solutions Team.

opt = passvalopt('textfun.delimlist', varargin{:});

%--------------------------------------------------------------------------

lead = opt.lead;
trail = opt.trail;
if isnumeric(lead)
    lead = repmat(' ', 1, lead);
end
if isnumeric(trail)
    trail = repmat(' ', 1, trail);
end
nLead = length(lead);
nTrail = length(trail);

% Set up the formatting string.
switch opt.quote
    case 'single'
        format = '''%s''';
    case 'double'
        format = '"%s"';
    otherwise
        format = '%s';
end
delim = opt.delimiter;
nDelim = length(delim);
format = [format, delim];

% The length of the formatting string needs to be added to the length of
% each list item.
nFormat = length(format) - 2;
len = cellfun(@length, c) + nFormat;

c = c(:).';
s = char( zeros(1, 0) );
isFirstRow = true;
while ~isempty(c)
    n = find(nLead + cumsum(len) + nTrail >= opt.wrap,1);
    if isempty(n)
        n = length(c);
    end
    s1 = [lead, sprintf(format, c{1:n}), trail];
    if ~isFirstRow
        s = [s, sprintf('\n')]; %#ok<AGROW>
    end
    s = [s, s1]; %#ok<AGROW>
    isFirstRow = false;
    c(1:n) = [ ];
    len(1:n) = [ ];
end

% Remove trailing delimiter.
if ~isempty(s)
    s = s(1:end-nDelim);
end

end
