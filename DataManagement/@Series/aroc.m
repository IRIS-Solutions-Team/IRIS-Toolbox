
function this = aroc(this, shift, varargin)

    if nargin<2
        shift = -1;
    end

    this = roc(this, shift, varargin{:}, "annualize", true);

end%

