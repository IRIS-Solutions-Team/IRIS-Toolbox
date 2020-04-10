function this = refresh(this, variantsRequested);
% refresh  Refresh dynamic links
%{
% Syntax
%--------------------------------------------------------------------------
%
%
%     model = refresh(model)
%
%
% Input Arguments
%--------------------------------------------------------------------------
%
%
% __`model`__ [ Model ] 
% > Model object whose dynamic links will be refreshed.
%
%
% Output Arguments
%--------------------------------------------------------------------------
%
%
% __`model`__ [ Model ] 
% > Model object with dynamic links refreshed.
%
%
% Description
%--------------------------------------------------------------------------
%
%
% Example
%--------------------------------------------------------------------------
%
%}

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

PTR = @int16;

if ~any(this.Link)
    return
end

nv = countVariants(this);
try
    if isequal(variantsRequested, Inf) || isequal(variantsRequested, @all)
        variantsRequested = 1 : nv;
    end
catch %#ok<CTCH>
    variantsRequested = 1 : nv;
end

%--------------------------------------------------------------------------

numQuantities = length(this.Quantity);

% Get a 1-(numQuantities+numStdCorr)-nv matrix of quantities and stdcorrs
x = [
    this.Variant.Values(:, :, variantsRequested), ...
    this.Variant.StdCorr(:, :, variantsRequested)
];

% Permute from 1-numQuantities-nv to numQuantities-nv-1
x = permute(x, [2, 3, 1]);

x = refresh(this.Link, x);

% Permute from (numQuantities+numStdCorr)-nv-1 to
% 1-(numQuantities+numStdCorr)-nv
x = ipermute(x, [2, 3, 1]);

this.Variant.Values(:, :, variantsRequested) = x(:, 1:numQuantities, :);
this.Variant.StdCorr(:, :, variantsRequested) = x(:, numQuantities+1:end, :);

end%

