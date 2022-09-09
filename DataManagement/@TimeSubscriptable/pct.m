function this = pct(this, varargin)

if isempty(this.Data)
    return
end

this = roc(this, varargin{:});
this.Data = 100*(this.Data - 1);

end%
