
function this = detrend(this, varargin)

    this = this - trend(this, varargin{:});

end%

