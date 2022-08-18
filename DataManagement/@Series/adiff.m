
function this = adiff(this, shift, varargin)

    if isempty(this.Data)
        return
    end

    try, shift;
        catch, shift = -1;
    end

    this = diff(this, shift, varargin{:}, "annualize", true);

end%

