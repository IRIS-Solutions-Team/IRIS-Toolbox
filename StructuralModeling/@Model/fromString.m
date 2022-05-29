% Type `web Model/fromString.md` to get help on this function
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function varargout = fromString(inputString, varargin)

    source = ModelSource.fromString(inputString, varargin{:});
    [varargout{1:nargout}] = Model(source, varargin{:});

end%

