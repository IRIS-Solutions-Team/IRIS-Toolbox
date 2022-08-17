% iris.root  Current IrisT root folder
%
% __Syntax__
%
%     iris.root()
%     root = iris.root()
%
%
% __Output Arguments__
%
% * `root` [ char | string ] - Path to the IrisT root folder.
%
%
% __Description__
%
% The `iris.root()` function is equivalent to the following call to
% [`iris.get`]().
%
%     iris.get('irisRoot')
%

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function irisRoot = root()

    irisRoot = iris.get('irisRoot');

end%

