
function this = apct(this, shift, varargin)

    if isempty(this.Data)
        return
    end

    if nargin<2
        shift = -1;
    end

    this = pct(this, shift, varargin{:}, "annualize", true);

end%

