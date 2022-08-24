
function This = permute(This,Order)

pp = inputParser( );
pp.addRequired('X',@(x) isa(x,'Series'));
pp.addRequired('Order',@(x) isnumeric(x) && ~isempty(x) && x(1) == 1);
pp.parse(This,Order);

This.data = permute(This.data,Order);
This.Comment = permute(This.Comment,Order);

end

