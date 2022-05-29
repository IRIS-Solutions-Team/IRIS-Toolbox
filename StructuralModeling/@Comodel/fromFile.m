% Type `web Comodel/fromFile.md` to get help on this function
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function this = fromFile(modelFile, condShocks, discount, varargin)

this = Comodel();

[this, opt, parserOpt, optimalOpt] = processConstructorOptions(this, varargin{:});
[this, opt] = file2model(this, modelFile, opt, opt.Preparser, parserOpt, optimalOpt, condShocks, discount);
this = build(this, opt);

end%

