function D = dbclip(D,Range)
% dbclip  Clip all tseries entries in database down to specified date range.
%
% Syntax
% =======
%
%     D = dbclip(D,Range)
%
% Input arguments
% ================
%
% * `D` [ struct ] - Database or nested databases with tseries objects.
%
% * `Range` [ numeric | cell ] - Range or a cell array of ranges to which
% all tseries objects will be clipped; multiple ranges can be specified,
% each for a different date frequency/periodicity.
%
% Output arguments
% =================
%
% * `D` [ struct ] - Database with tseries objects cut down to `range`.
%
% Description
% ============
%
% This functions looks up all tseries objects within the database `d`,
% including tseries objects nested in sub-databases, and cuts off any
% values preceding the start date of `Range` or following the end date of
% `range`. The tseries object comments, if any, are preserved in the new
% database.
%
% If a tseries entry does not match the date frequency of the input range,
% a warning is thrown.
%
% Multiple ranges can be specified in `Range` (as a cell array), each for a
% different date frequency/periodicity (i.e. one or more of the following:
% monthly, bi-monthly, quarterly, half-yearly, yearly, indeterminate). Each
% tseries entry will be clipped to the range that matches its date
% frequency.
%
% Example
% ========
%
%     d = struct( );
%     d.x = Series(qq(2005,1):qq(2010,4),@rand);
%     d.y = Series(qq(2005,1):qq(2010,4),@rand)
%
%     d =
%        x: [24x1 tseries]
%        y: [24x1 tseries]
%
%     dbclip(d,qq(2007,1):qq(2007,4))
%
%     ans =
%         x: [4x1 tseries]
%         y: [4x1 tseries]

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

pp = inputParser( );
pp.addRequired('D',@isstruct);
pp.addRequired('Range', ...
    @(x) isnumeric(x) || (iscell(x) && all(cellfun(@isnumeric,x))));
pp.parse(D,Range);

if isnumeric(Range)
    Range = {Range};
end

%--------------------------------------------------------------------------

inpFreq = rngfreq(Range);
list = fieldnames(D);
nList = length(list);
freqMatched = true(1,nList);
for i = 1 : nList
    name = list{i};
    if isa(D.(name),'tseries') && ~isempty(D.(name))
        % Clip a tseries entry.
        xFreq = DateWrapper.getFrequencyFromNumeric(D.(name).start);
        pos = find(xFreq == inpFreq,1);
        if isempty(pos)
            freqMatched(i) = false;
            continue
        end
        D.(name) = resize(D.(name), Range{pos});
    elseif isstruct(D.(name))
        % Clip a sub-database.
        D.(name) = dbclip(D.(name), Range);
    end
end

if any(~freqMatched)
    utils.warning('dbase:dbclip', ...
        ['This tseries not resized because ', ...
        'no input range matches its date frequency: ''%s''.'], ...
        list{~freqMatched});
end

end
