function varargout = findname(This,varargin)
% findname  Find names of variables, shocks, or parameters by their descriptors.
%
% Syntax
% =======
%
%     [Name,Name,...] = findname(M,Desc,Desc,...)
%     [List,List,...] = findname(M,'-rexp',Rexp,Rexp,...)
%
% Input arguments
% ================
%
% * `M` [ model ] - Model object in which the names will be searched for.
%
% * `Desc` [ char ] - Variable, shock, or parameter descriptors that will
% be searched for.
%
% * `Rexp` [ char ] - Regular expressions that will be matched against
% variable, shock, and parameter descriptors.
%
% Output arguments
% =================
%
% * `Name` [ char ] - First name found with the descriptor `Desc`.
%
% * `List` [ cellstr ] - List of names whose descriptors match the regular
% expression `Rexp`.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

if nargin < 2
    return
end

[varargout{1:nargout}] = myfind(This,'findname',varargin{:});

end
