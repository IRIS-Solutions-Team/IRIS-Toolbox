function this = stdscale(this, factor)
% stdscale  Rescale all std deviations by the same factor.
%
% Syntax
% =======
%
%     This = stdscale(This, Factor)
%
% Input arguments
% ================
%
% * `This` [ model ] - Model object whose std deviations will be rescaled.
%
% * `Factor` [ numeric ] - Factor by which all std deviations in the model
% object `This` will be rescaled.
%
% Output arguments
% =================
%
% * `This` [ model ] - Model object with all of std deviations rescaled.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

TYPE = @int8;

%--------------------------------------------------------------------------

nAlt = length(this.Variant);
ne = sum(this.Quantity.Type==TYPE(31) | this.Quantity.Type==TYPE(32));

factor = factor(:);
if all(factor==1)
    return
elseif all(factor==0)
    for iAlt = 1 : nAlt
        this.Variant{iAlt}.StdCorr(1, 1:ne) = 0;
    end
    return
end

nFactor = length(factor);
if nFactor==1 && nAlt>1
    factor = repmat(factor, 1, nAlt);
end

for iAlt = 1 : nAlt
    this.Variant{iAlt}.StdCorr(1, 1:ne) = ...
        this.Variant{iAlt}.StdCorr(1, 1:ne) * factor(iAlt);
end

end
