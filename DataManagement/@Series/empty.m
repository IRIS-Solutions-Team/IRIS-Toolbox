% Type `web Series/empty.md` for help on this function
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2021 IRIS Solutions Team

function this = empty(varargin)

if nargin==1 && isa(varargin{1}, 'TimeSubscriptable')
    this = varargin{1};
    this.Start = TimeSubscriptable.StartDateWhenEmpty;
    data = this.Data;
    ndimsData = ndims(data);
    ref = repmat({':'}, 1, ndimsData);
    ref(1) = {[]};
    this.Data = data(ref{:});
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

