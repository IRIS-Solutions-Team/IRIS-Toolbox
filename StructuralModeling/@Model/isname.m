%{
% 
% # `isname` ^^(Model)^^
% 
% {== True for valid names of variables, parameters, or shocks in model object. ==}
% 
% 
% ## Syntax 
% 
%     Flag = isname(M,Name)
%     [Flag,Flag,...] = isname(M,Name,Name,...)
% 
% 
% ## Input arguments 
% 
%  `M` [ model ]
% > 
% > Model object.
% >
%  
%  `Name` [ char ]
% > 
% > A text string that will be matched against the names
% > of variables, parameters and shocks in the model object `M`.
% >
% 
% ## Output arguments 
% 
% `Flag` [ `true` | `false` ] 
% >
% >True for input strings that are valid
% >names in the model object `M`.
% >
% 
% ## Options 
% 
% 
% ## Description 
% 
% 
% 
% ## Examples
% 
% 
%}
% --8<--


function varargout = isname(this, varargin)

[varargout{1:nargout}] = isName(this.Quantity, varargin{:});

end