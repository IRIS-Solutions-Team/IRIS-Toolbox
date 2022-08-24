
function this = difflog(this, varargin)

    if isempty(this.Data)
        return
    end

    this.Data = log(this.Data);
    this = diff(this, varargin{:});

end%

