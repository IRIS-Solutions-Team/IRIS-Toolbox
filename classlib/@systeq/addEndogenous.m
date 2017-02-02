function this = addEndogenous(this, varargin)

TYPE = @int8;

%--------------------------------------------------------------------------

this = addQuantity(this, TYPE(2), varargin{:});

end