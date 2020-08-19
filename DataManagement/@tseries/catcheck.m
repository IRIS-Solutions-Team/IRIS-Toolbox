function [output, inxOfSeries, inxOfNumeric] = catcheck(varargin)
% catcheck  Check input arguments before concatenating Series objects
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 IRIS Solutions Team

%--------------------------------------------------------------------------

% Time series versus other inputs
inxOfSeries = false(1, nargin);
inxOfNumeric = false(1, nargin);
for i = 1 : nargin
    inxOfSeries(i) = isa(varargin{i}, 'tseries');
    inxOfNumeric(i) = isnumeric(varargin{i});
end
inxToRemove = ~inxOfSeries & ~inxOfNumeric;

% Remove non-Series or non-numeric inputs and throw warning
if any(inxToRemove)
    throw( exception.Base('Series:InputsRemovedFromCat', 'warning') );
    varargin(inxToRemove) = [ ]; %#ok<UNRCH>
    inxOfSeries(inxToRemove) = [ ];
    inxOfNumeric(inxToRemove) = [ ];
end

% Check frequencies
freq = zeros(size(varargin));
freq(~inxOfSeries) = Inf;
start = nan(size(inxOfSeries));
for i = find(inxOfSeries)
    start(i) = varargin{i}.Start;
end
freq(inxOfSeries) = dater.getFrequency(start(inxOfSeries));
indexNaN = isnan(freq);
if sum(~indexNaN & inxOfSeries)>1 ...
   && any( diff(freq(~indexNaN & inxOfSeries))~=0 )
    throw( exception.Base('Series:CannotCatMixedFrequencies', 'error') );
end
output = varargin;

end%

