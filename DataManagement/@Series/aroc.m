
function this = aroc(this, shift, varargin)

    try, shift;
        catch, shift = -1;
    end

    this = roc(this, shift, varargin{:}, "annualize", true);

end%

