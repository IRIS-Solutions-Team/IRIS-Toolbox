% empty  Create empty time series or empty existing time series
%
% __Syntax__
%
%     x = Series.empty([0, size, ...])
%     x = Series.empty(0, size, ...)
%     x = Series.empty(x)
%
% 
% __Input Arguments__
%
% * `size` [ numeric ] - Size of new time series in 2nd and higher
% dimensions; first dimenstion (time) must be always 0.
%
% * `this` [ Series ] - Input time series that will be emptied.
%
%
% __Output Arguments__
%
% * `this` [ Series ] - Empty time series with the 2nd and higher
% dimensions the same size as the input time series, and comments
% preserved.
%
%
% __Description__
%
%
% __Example__
%

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

function this = empty(varargin)

if nargin==1 && isa(varargin{1}, 'TimeSubscriptable')
    this = varargin{1};
    this.Start = TimeSubscriptable.StartDateWhenEmpty;
    newSize = size(this.Data);
    newSize(1) = 0;
    this.Data = double.empty(newSize);
else
    this = Series( );
    if isempty(varargin)
        newData = double.empty(0, 1);
    else
        newData = double.empty(varargin{:});
    end
    if size(newData, 1)~=0
        exception.error([
            "Series:InvalidEmptyData"
            "When creating an empty time series, "
            "first dimension (time dimension) must be zero."
        ]);
    end
    this.Start = TimeSubscriptable.StartDateWhenEmpty;
    this.Data = newData;
    this = resetComment(this);
end

end%

