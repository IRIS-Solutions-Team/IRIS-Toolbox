function [quantities, equations] = byAttributes(this, varargin)

quantities = byAttributes(this.Quantity, varargin{:});
if nargout>=2
    equations = byAttributes(this.Equation, varargin{:});
end

end%

