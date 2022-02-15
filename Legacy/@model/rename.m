function this = rename(this, varargin)

if ~isempty(varargin)
    this.Quantity = rename(this.Quantity, varargin{:});
else
    this.Quantity = resetNames(this.Quantity);
end

end%

