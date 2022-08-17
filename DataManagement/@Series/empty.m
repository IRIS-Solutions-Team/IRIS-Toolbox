function this = empty(varargin)

if nargin==1 && isa(varargin{1}, 'Series')
    this = varargin{1};
    this.Start = Series.StartDateWhenEmpty;
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
    this.Start = Series.StartDateWhenEmpty;
    this.Data = newData;
    this = resetComment(this);
end

end%

