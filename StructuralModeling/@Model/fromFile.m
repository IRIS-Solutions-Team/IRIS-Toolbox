% Type `web Model/fromFile.md` to get help on this function
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2021 [IrisToolbox] Solutions Team

function varargout = fromFile(fileName, varargin)

source = ModelSource.fromFile(fileName, varargin{:});
[varargout{1:nargout}] = Model(source, varargin{:});

end%

