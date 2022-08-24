
function this = diff(this, shift, varargin)

    if isempty(this.Data)
        return
    end

    try, shift;
        catch, shift = -1;
    end

    if isnumeric(shift) && numel(shift)>1
        for s = reshape(shift, 1, []);
            this = diff(this, s, varargin{2:end});
        end
        return
    end

    [shift, power] = dater.resolveShift(getRangeAsNumeric(this), shift, varargin{:});

    if isempty(this.Data)
        return
    end


    %===========================================================================
    this = unop(@series.change, this, 0, @minus, shift);
    %===========================================================================


    if power~=1
        this.Data = this.Data * power;
    end

end%

