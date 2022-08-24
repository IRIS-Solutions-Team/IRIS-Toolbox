function [Min,Inx] = min(This,Dim)

try
    Dim; %#ok<VUNUS>
catch
    Dim = 1;
end

%--------------------------------------------------------------------------

[Min,Inx] = unopinx(@min,This,Dim,[ ],Dim);

end
