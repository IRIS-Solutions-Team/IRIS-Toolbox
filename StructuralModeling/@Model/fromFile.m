% Type `web Model/fromFile.md` to get help on this function
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2021 [IrisToolbox] Solutions Team

function this = fromFile(modelFile, varargin)

if (isstring(modelFile) || iscellstr(modelFile)) && numel(modelFile)>1
    modelFile = string(modelFile);
end

this = Model(modelFile, varargin{:});

end%

