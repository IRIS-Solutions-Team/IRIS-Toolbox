function this = empty(varargin)
% empty  Create empty time series or empty an existing time series
%
% __Syntax__
%
%     x = tseries.empty([0, size, ...])
%     x = tseries.empty(0, size, ...)
%     x = tseries.empty(x)
%
% 
% __Input Arguments__
%
% * `size` [ numeric ] - Size of new time series in 2nd and higher
% dimensions; first dimenstion (time) must be always 0.
%
% * `this` [ tseries ] - Input time series that will be emptied.
%
%
% __Output Arguments__
%
% * `this` [ tseries ] - Empty time series with the 2nd and higher
% dimensions the same size as the input time series, and comments
% preserved.
%
%
% __Description__
%
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

%--------------------------------------------------------------------------

nanDate = DateWrapper(NaN);
if nargin==1 && isa(varargin{1}, 'TimeSubscriptable')
    this = varargin{1};
    this.Start = nanDate;
    newSize = size(this.Data);
    newSize(1) = 0;
    this.Data = double.empty(newSize);
else
    this = tseries( );
    if isempty(varargin)
        newData = double.empty(0, 1);
    else
        newData = double.empty(varargin{:});
    end
    assert( ...
        size(newData, 1)==0, ...
        exception.Base('Series:TimeDimMustBeZero', 'error') ...
    );
    this.Start = nanDate;
    this.Data = newData;
    this = resetColumnNames(this);
end

end
