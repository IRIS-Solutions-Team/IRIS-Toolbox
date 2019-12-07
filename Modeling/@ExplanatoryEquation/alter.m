function this = alter(this, newNumVariants, varargin)
% alter  Expand or reduce the number of parameter variants in ExplanatoryEquation
%{
%}

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2019 IRIS Solutions Team

persistent pp
if isempty(pp)
    pp = extend.InputParser('ExplanatoryEquation.alter');
    addRequired(pp, 'explanatoryEquation', @(x) isa(x, 'ExplanatoryEquation'));
    addRequired(pp, 'newNumVariants', @(x) validate.roundScalarInRange(x, 1, Inf));
    addOptional(pp, 'reset', false, @validate.logicalScalar);
end
parse(pp, this, newNumVariants, varargin{:});
reset = pp.Results.reset;

%--------------------------------------------------------------------------

nv = countVariants(this);
if newNumVariants==nv && isequal(reset, false)
    return
end

for i = 1 : numel(this)
    this__ = this(i);
    listStatistics = reshape(string(fieldnames(this__.Statistics)), 1, [ ]);
    if reset
        this__.Parameters(:, :, :) = NaN;
        for name = listStatistics
            this__.Statistics.(name)(:, :, :) = NaN;
        end
    end
    if nv>newNumVariants
        this__.Parameters = this__.Parameters(:, :, 1:newNumVariants);
        for name = listStatistics
            this__.Statistics.(name) = this__.Statistics.(name)(:, :, 1:newNumVariants);
        end
    elseif nv<newNumVariants
        numToAdd = newNumVariants - nv;
        this__.Parameters(:, :, end+1:newNumVariants) = repmat(this__.Parameters(:, :, end), 1, 1, numToAdd);
        for name = listStatistics
            this__.Statistics.(name)(:, :, end+1:newNumVariants) = repmat(this__.Statistics.(name)(:, :, end), 1, 1, numToAdd);
        end
    end
    this(i) = this__;
end

end%
