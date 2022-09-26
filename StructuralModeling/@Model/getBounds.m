%{
% 
% # `getBounds` ^^(Model)^^
% 
% {== Get lower and upper bounds imposed on model quantities ==}
% 
% 
% ## Syntax 
% 
%     [___] = getBounds(___)
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


function bounds = getBounds(this, varargin)

bounds = getBounds(this.Quantity, varargin{:});

end%

