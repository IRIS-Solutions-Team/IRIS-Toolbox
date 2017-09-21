function this = refresh(this, variantsRequested)
% refresh  Refresh dynamic links.
%
% __Syntax__
%
%     M = refresh(M)
%
%
% __Input Arguments__
%
% * `M` [ model ] - Model object whose dynamic links will be refreshed.
%
%
% __Output Arguments__
%
% * `M` [ model ] - Model object with dynamic links refreshed.
%
%
% __Description__
%
%
% __Example__
%
%     m = refresh(m)
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

PTR = @int16;

if ~any(this.Link)
    return
end

nv = length(this);
try
    if isequal(variantsRequested, Inf) || isequal(variantsRequested, @all)
        variantsRequested = 1 : nv;
    end
catch %#ok<CTCH>
    variantsRequested = 1 : nv;
end

%--------------------------------------------------------------------------

numOfQuantities = length(this.Quantity);

% Get a 1-(numOfQuantities+numOfStdCorr)-nv matrix of quantities and stdcorrs.
x = [ ...
    this.Variant.Values(:, :, variantsRequested), ...
    this.Variant.StdCorr(:, :, variantsRequested), ...
];

% Permute from 1-numOfQuantities-nv to numOfQuantities-nv-1.
x = permute(x, [2, 3, 1]);

x = refresh(this.Link, x);

% Permute from (numOfQuantities+numOfStdCorr)-nv-1 to
% 1-(numOfQuantities+numOfStdCorr)-nv.
x = ipermute(x, [2, 3, 1]);

this.Variant.Values(:, :, variantsRequested) = x(:, 1:numOfQuantities, :);
this.Variant.StdCorr(:, :, variantsRequested) = x(:, numOfQuantities+1:end, :);

end
