function Dates = find(X,Func)

try
    Func; %#ok<VUNUS>
catch
    Func = @all;
end

pp = inputParser( );
pp.addRequired('X',@(x) isa(x,'Series'));
pp.addRequired('Func',@(x) isequal(x,@all) || isequal(x,@any));
pp.parse(X,Func);

%--------------------------------------------------------------------------

ix = Func(X.data(:,:),2);
Dates = X.start + find(ix) - 1;

end

