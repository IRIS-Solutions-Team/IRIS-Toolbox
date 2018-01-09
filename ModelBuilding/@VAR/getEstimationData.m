function [y, x, range] = getEstimationData(this, d, range, p)
% getEstimationData  Retrieve input data and range including pre-sample for estimation.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

isPanel = ispanel(this);
ky = length(this.NamesEndogenous);
kx = length(this.NamesExogenous);
range = range(:).';
nGrp = max(1, length(this.GroupNames));
y = cell(1, nGrp);
x = cell(1, nGrp);
lsyx = [this.NamesEndogenous, this.NamesExogenous];

sw = struct( );
sw.BaseYear = this.BaseYear;

if isPanel
    % Check if all group names are contained withing the input database.
    chkGroupNames( );
    if any(isinf(range(:)))
        throw( exception.Base('VAR:CANNOT_INF_RANGE_IN_PANEL', 'error') );
    end
end
isFirstInf = isinf(range(1));
isLastInf = isinf(range(end));

for iGrp = 1 : nGrp
    if ~isPanel
        % Capture range on output to deal with -Inf, Inf.
        [yx, ~, range] = db2array(d, lsyx, range, sw);
    else
        name = this.GroupNames{iGrp};
        yx = db2array(d.(name), lsyx, range, sw);
    end
    if isempty(yx)
        yx = nan(0, ky+kx);
    end
    yx = permute(yx, [2, 1, 3]);
    % Set exogenous variables to NaN in pre-sample init condition.
    yx(ky+(1:kx), 1:p, :) = NaN;
    y{iGrp} = yx(1:ky, :, :);
    x{iGrp} = yx(ky+(1:kx), :, :);
    if ~isPanel
        clipRange( );
    end
end

return




    function chkGroupNames( )
        found = true(1,nGrp);
        for iiGrp = 1 : nGrp
            if ~isfield(d,this.GroupNames{iiGrp})
                found(iiGrp) = false;
            end
        end
        if any(~found)
            throw( exception.Base('VAR:GROUP_NOT_INPUT_DATA', 'error'), ...
                this.GroupNames{~found} );
        end
    end




    function clipRange( )
        % Clip the range if user specified -Inf or Inf at either range end. Do not
        % use X to determine the start and end of the range because this could
        % result in unncessary removal of lags of endogenous variables.
        if isFirstInf
            sample = ~any( any(isnan(y{1}), 3), 1 );
            first = find(sample, 1);
            y{iGrp} = y{iGrp}(:, first:end, :);
            x{iGrp} = x{iGrp}(:, first:end, :);
            range = range(first:end);
        end
        if isLastInf
            sample = ~any( any(isnan(y{iGrp}), 3), 1 );
            last = find(sample, 1, 'last');
            y{iGrp} = y{iGrp}(:, 1:last, :);
            x{iGrp} = x{iGrp}(:, 1:last, :);
            range = range(1:last);
        end
    end
end
