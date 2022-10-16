% reset  Reset parameter variants in Explanatory
%{
%}

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 IRIS Solutions Team

function this = reset(this)

    nv = countVariants(this);

    for i = 1 : numel(this)
        this__ = this(i);

        if ~isempty(this__.ResidualModel)
            this__.ResidualModel = reset(this__.ResidualModel);
        end

        listStatistics = reshape(string(fieldnames(this__.Statistics)), 1, []);
        this__.Parameters(:, :, :) = NaN;
        for name = listStatistics
            if iscell(this__.Statistics.(name))
                this__.Statistics.(name)(:, :, :) = {[]};
            else
                this__.Statistics.(name)(:, :, :) = NaN;
            end
        end

        this(i) = this__;
    end

end%

