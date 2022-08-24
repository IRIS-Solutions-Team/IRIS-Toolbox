function [Max, Inx] = max(This, Dim)

try
    Dim; %#ok<VUNUS>
catch
    Dim = 1;
end

%--------------------------------------------------------------------------

[Max, Inx] = unopinx(@max, This, Dim, [ ], Dim);

end
