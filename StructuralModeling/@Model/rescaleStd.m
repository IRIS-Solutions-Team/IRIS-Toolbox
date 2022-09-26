%{
% 
% # `rescaleStd` ^^(Model)^^
% 
% {== Rescale all std deviations by the same factor ==}
% 
% 
% ## Syntax
% 
%     model = rescaleStd(model, factor)
% 
% 
% ## Input arguments
% 
% __`model`__ [ Model ] 
% > 
% > Model object whose std deviations will be rescaled.
% > 
% 
% __`factor`__ [ numeric ] 
% > 
% > Factor by which all std deviations in the model
% > object `model` will be rescaled.
% > 
% 
% ## Output arguments
% > 
% > __`model`__ [ Model ] 
% > 
% > Model object with all of std deviations rescaled.
% > 
% 
% ## Description
% 
% 
% ## Example
% 
% 
%}
% --8<--


function this = rescaleStd(this, factor)

    ne = nnz(this.Quantity.Type==31 | this.Quantity.Type==32);

    factor = reshape(factor, [], 1);
    if all(factor==1)
        return
    elseif all(factor==0)
        this.Variant.StdCorr(:, 1:ne, :) = 0;
        return
    end

    nv = countVariants(this);
    numFactors = numel(factor);
    if numFactors==1 && nv>1
        factor = repmat(factor, 1, nv);
    end

    for v = 1 : nv
        this.Variant.StdCorr(:, 1:ne, v) = this.Variant.StdCorr(:, 1:ne, v) * factor(v);
    end

end%

