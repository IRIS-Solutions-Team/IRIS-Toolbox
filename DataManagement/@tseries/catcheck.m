function [outp, ixTseries, ixNumeric] = catcheck(varargin)
% catcheck  Check input arguments before concatenating Series objects.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

% Series vs non-Series inputs.
ixTseries = false(1, nargin);
ixNumeric = false(1, nargin);
for i = 1 : nargin
    ixTseries(i) = isa(varargin{i}, 'tseries');
    ixNumeric(i) = isnumeric(varargin{i});
end
ixRemove = ~ixTseries & ~ixNumeric;

% Remove non-Series or non-numeric inputs and display warning.
if any(ixRemove)
    throw( ...
        exception.Base('Series:InputsRemovedFromCat', 'warning') ...
        );
    varargin(ixRemove) = [ ]; %#ok<UNRCH>
    ixTseries(ixRemove) = [ ];
    ixNumeric(ixRemove) = [ ];
end

% Check frequencies.
freq = zeros(size(varargin));
freq(~ixTseries) = Inf;
start = nan(size(ixTseries));
for i = find(ixTseries)
    start(i) = varargin{i}.start;
end
freq(ixTseries) = DateWrapper.getFrequencyFromNumeric(start(ixTseries));
ixNan = isnan(freq);
if sum(~ixNan & ixTseries)>1 ...
        && any( diff(freq(~ixNan & ixTseries))~=0 )
    throw( ...
        exception.Base('Series:CannotCatMixedFrequencies', 'error') ...
        );
end
outp = varargin;

end
