%{
% 
% # `isempty` ^^(Model)^^
% 
% {== True for empty model object==}
% 
% 
% ## Syntax 
% 
%     flag = isempty(m)
% 
% 
% ## Input arguments 
% 
% `m` [ model ]
% > 
% > Model object.
% > 
% 
% 
% ## Output arguments 
% 
% `flag` [ `true` | `false` ]
% > 
% > True if the model object has zero
% > parameter variants or contains no variables.
% > 
% 
% 
% ## Options 
% 
% 
% 
% ## Description 
% 
% 
% 
% ## Examples
% 
%}
% --8<--


function flag = isempty(m)

flag = length(m)==0 || isempty(m.Quantity);

end%

