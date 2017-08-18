function d = dboverlay(d, varargin)
% dboverlay  Combine time series observations from two or more databases.
%
% Syntax
% =======
%
%     D = dboverlay(D, D1, D2,...)
%
%
% Input arguments
% ================
%
% * `D` [ struct ] - Primary input database.
%
% * `D1`, `D2`, ... [ struct ] - Databases whose tseries observations will
% be used to extend or overwrite observations in the tseries objects of the
% same name in the primary database.
%
%
% Output arguments
% =================
%
% * `D` [ struct ] - Output database.
%
%
% Description
% ============
%
% If more than two databases are combined then they are processed
% one-by-one: the first is combined with the second, then the result is
% combined with the third, and so on, using the following rules:
%
% * If two non-empty tseries objects with the same frequency are combined,
% the observations are spliced together. If some of the observations
% overlap the observations from the second tseries are used.
% * If two empty tseries objects are combined the first is used.
% * If a non-empty tseries is combined with an empty tseries, the non-empty
% one is used.
% * If two objects are combined of which at least one is a non-tseries
% object, the second input object is used.
%
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

if ~isstruct(d) || any(~cellfun(@isstruct, varargin))
    utils.error('dbase:dboverlay', ...
        'All input arguments must be structs (databases).');
end

if length(varargin)>1
    for i = 1 : length(varargin)
        d = dboverlay(d, varargin{i});
    end
    return
end

%--------------------------------------------------------------------------

s = varargin{1};
dList = fieldnames(d);
sList = fieldnames(s);
combList = union(dList, sList);
for j = 1 : numel(combList)
    if ~isfield(s, combList{j})
        continue
    end
    if ~isfield(d, combList{j})
        d.(combList{j}) = s.(combList{j});
        continue
    end
    x = d.(combList{j});
    y = s.(combList{j});
    if isa(x, 'tseries') && isa(y, 'tseries')
        if freq(x)==freq(y)
            % Two non-empty time series with the same frequency.
            d.(combList{j}) = vertcat(x, y);
        elseif isempty(x.data)
            % Two empty time series or the first non-empty and the
            % second empty; use the first input anyway.
            d.(combList{j}) = y;
        elseif isempty(y.data)
            % Only the second time series is non-empty.
            d.(combList{j}) = x;
        else
            % Two non-empty time series with different frequencies.
            d.(combList{j}) = x;
        end
    else
        % At least one non-series input, use the second input.
        d.(combList{j}) = y;
    end
end
tempList = fieldnames(s);
tempList = setdiff(tempList, combList);
for j = 1 : length(tempList)
    d.(tempList{j}) = s.(tempList{j});
end

end
