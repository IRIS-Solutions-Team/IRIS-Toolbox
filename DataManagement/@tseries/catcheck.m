function [output, indexTimeSeries, indexNumeric] = catcheck(varargin)
% catcheck  Check input arguments before concatenating Series objects.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

%--------------------------------------------------------------------------

% Series vs non-Series inputs.
indexTimeSeries = false(1, nargin);
indexNumeric = false(1, nargin);
for i = 1 : nargin
    indexTimeSeries(i) = isa(varargin{i}, 'tseries');
    indexNumeric(i) = isnumeric(varargin{i});
end
indexToRemove = ~indexTimeSeries & ~indexNumeric;

% Remove non-Series or non-numeric inputs and display warning.
if any(indexToRemove)
    throw( ...
        exception.Base('Series:InputsRemovedFromCat', 'warning') ...
    );
    varargin(indexToRemove) = [ ]; %#ok<UNRCH>
    indexTimeSeries(indexToRemove) = [ ];
    indexNumeric(indexToRemove) = [ ];
end

% Check frequencies.
freq = zeros(size(varargin));
freq(~indexTimeSeries) = Inf;
start = nan(size(indexTimeSeries));
for i = find(indexTimeSeries)
    start(i) = varargin{i}.start;
end
freq(indexTimeSeries) = DateWrapper.getFrequencyFromNumeric(start(indexTimeSeries));
indexNaN = isnan(freq);
if sum(~indexNaN & indexTimeSeries)>1 ...
        && any( diff(freq(~indexNaN & indexTimeSeries))~=0 )
    throw( ...
        exception.Base('Series:CannotCatMixedFrequencies', 'error') ...
    );
end
output = varargin;

end
