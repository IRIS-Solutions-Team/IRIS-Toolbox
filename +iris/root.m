function irisRoot = root( )
% iris.root  Current IRIS root folder
%
% __Syntax__
%
%     iris.root
%     Root = iris.root( )
%
%
% __Output Arguments__
%
% * `Root` [ char ] - Path to the IRIS root folder.
%
%
% __Description__
%
% The `irisroot` function is equivalent to the following call to
% [`irisget`](config/irisget)
%
%     iris.get('IrisRoot')
%

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2018 IRIS Solutions Team

%--------------------------------------------------------------------------

irisRoot = iris.get('IrisRoot');

end
