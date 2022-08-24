
function this = apct(this, shift, varargin)

    if isempty(this.Data)
        return
    end

    try, shift;
        catch, shift = -1;
    end

    this = pct(this, shift, varargin{:}, "annualize", true);

end%

