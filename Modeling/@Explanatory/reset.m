% reset  Reset parameter variants in Explanatory
%{
%}

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 IRIS Solutions Team

function this = reset(this)

nv = countVariants(this);

for i = 1 : numel(this)
    this__ = this(i);

    if ~isempty(this__.ResidualModel)
        this__.ResidualModel = reset(this__.ResidualModel);
    end

    listStatistics = reshape(string(fieldnames(this__.Statistics)), 1, [ ]);
    this__.Parameters(:, :, :) = NaN;
    for name = listStatistics
        this__.Statistics.(name)(:, :, :) = NaN;
    end

    this(i) = this__;
end

end%

