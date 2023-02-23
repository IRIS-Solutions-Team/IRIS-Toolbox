
function this = adiff(this, shift, varargin)

    if isempty(this.Data)
        return
    end

    if nargin<2
        shift = -1;
    end

    this = diff(this, shift, varargin{:}, "annualize", true);

end%

