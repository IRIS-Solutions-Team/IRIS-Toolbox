% alter  Expand or reduce the number of parameter variants in Explanatory
%{
%}

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 IRIS Solutions Team

function this = alter(this, newNumVariants, varargin)

reset = false;
if ~isempty(varargin) && isequaln(varargin{1}, NaN)
    reset = true;
end

nv = countVariants(this);
if newNumVariants==nv && ~reset
    return
end

for i = 1 : numel(this)
    this__ = this(i);

    if ~isempty(this__.ResidualModel)
        this__.ResidualModel = alter(this__.ResidualModel, newNumVariants, varargin{:});
    end

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
