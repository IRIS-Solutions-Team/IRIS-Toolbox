function [quantities, equations] = byAttributes(this, attributes)

quantities = byAttributes(this.Quantity, attributes);
if nargout>=2
    equations = byAttributes(this.Equation, attributes);
end

end%

