
function this = adifflog(this, varargin)

    if isempty(this.Data)
        return
    end

    this = difflog(this, varargin{:}, "annualize", true);

end%

