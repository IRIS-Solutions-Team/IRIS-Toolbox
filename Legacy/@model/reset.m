% Type `web Model/reset.md` for help on this function.
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function this = reset(this, varargin)

inxY = this.Quantity.Type==1;
inxX = this.Quantity.Type==2;
inxE = this.Quantity.Type==31 | this.Quantity.Type==32;
inxP = this.Quantity.Type==4;
inxG = this.Quantity.Type==5;
numE = nnz(inxE);

if this.LinearStatus
    defaultStd = this.DEFAULT_STD_LINEAR;
else
    defaultStd = this.DEFAULT_STD_NONLINEAR;
end

if isempty(varargin)
    resetSteady( );
    resetPlainParameters( );
    resetStd( );
    resetCorr( );
    return
end

for i = 1 : numel(varargin)
    x = strip(string(varargin{i}));
    if any(startsWith(x, ["sstate", "steady"], "ignoreCase", true))
        resetSteady( );
    elseif startsWith(x, "plain", "ignoreCase", true)
        resetPlainParameters( );
    elseif startsWith(x, "param", "ignoreCase", true)
        resetPlainParameters( );
        resetStd( );
        resetCorr( );
    elseif startsWith(x, "stdcorr", "ignoreCase", true)
        resetStd( );
        resetCorr( );
    elseif startsWith(x, "std", "ignoreCase", true)
        resetStd( );
    elseif startsWith(x, "corr", "ignoreCase", true)
        resetCorr( );
    end
end

return

    function resetSteady( )
        this.Variant.Values(:, inxX | inxY, :) = NaN;
    end%


    function resetPlainParameters( )
        this.Variant.Values(:, inxP, :) = NaN;
    end%


    function resetStd( )
        this.Variant.StdCorr(:, 1:numE, :) = defaultStd;
    end%


    function resetCorr( )
        this.Variant.StdCorr(:, numE+1:end, :) = 0;
    end%
end%
