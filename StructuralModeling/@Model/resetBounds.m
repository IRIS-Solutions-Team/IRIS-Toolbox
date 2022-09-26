%{
% 
% # `resetBounds` ^^(Model)^^
% 
% {== Reset lower and upper bounds imposed on model quantities ==}
% 
% 
% ## Syntax 
% 
%     [___] = resetBounds(___)
% 
% 
% ## Input arguments 
% 
% __`xxx`__ [ xxx | ___ ]
% > 
% > Description
% > 
% 
% 
% ## Output arguments 
% 
% __`yyy`__ [ yyy | ___ ]
% > 
% > Description
% > 
% 
% 
% ## Options 
% 
% __`zzz=default`__ [ zzz | ___ ]
% > 
% > Description
% > 
% 
% 
% ## Description 
% 
% 
% 
% ## Examples
% 
% ```matlab
% ```
% 
%}
% --8<--


function this = resetBounds(this)

this.Quantity = resetBounds(this.Quantity);

end%

