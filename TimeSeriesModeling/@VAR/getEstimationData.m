function [y, x, extdRange] = getEstimationData(this, d, range, p, startDate)
% getEstimationData  Retrieve input data and determine extended range 
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 IRIS Solutions Team

%--------------------------------------------------------------------------

range = double(range);

% Get extended range including pre-sample
if strcmpi(startDate, 'Presample')
    % User entered range including pre-sample
    extdRange = range;
elseif strncmpi(startDate, 'Fit', 3)
    % User entered fit range excluding pre-sample
    if isinf(range(1))
        extdRange = range;
    else
        extdRange = dater.colon(dater.plus(range(1), -p), range(end));
    end
end

ky = this.NumEndogenous;
kx = this.NumExogenous;
extdRange = reshape(extdRange, 1, [ ]);
numGroups = max(1, this.NumGroups);
y = cell(1, numGroups);
x = cell(1, numGroups);
lsyx = [this.EndogenousNames, this.ExogenousNames];

sw = struct( );
sw.BaseYear = this.BaseYear;

if this.IsPanel
    % Check if all group names are contained withing the input database.
    hereCheckGroupNames( );
    if any(isinf(extdRange(:)))
        throw( exception.Base('VAR:CANNOT_INF_RANGE_IN_PANEL', 'error') );
    end
end
isFirstInf = isinf(extdRange(1));
isLastInf = isinf(extdRange(end));

for iGrp = 1 : numGroups
    if ~this.IsPanel
        % Capture range on output to deal with -Inf, Inf.
        [yx, ~, extdRange] = db2array(d, lsyx, extdRange, sw);
    else
        name = this.GroupNames(iGrp);
        yx = db2array(d.(name), lsyx, extdRange, sw);
    end
    if isempty(yx)
        yx = nan(0, ky+kx);
    end
    yx = permute(yx, [2, 1, 3]);
    % Set exogenous variables to NaN in pre-sample init condition.
    yx(ky+(1:kx), 1:p, :) = NaN;
    y{iGrp} = yx(1:ky, :, :);
    x{iGrp} = yx(ky+(1:kx), :, :);
    if ~this.IsPanel
        clipRange( );
    end
end

return


    function hereCheckGroupNames( )
        found = true(1, numGroups);
        for iiGrp = 1 : numGroups
            if ~isfield(d, this.GroupNames(iiGrp))
                found(iiGrp) = false;
            end
        end
        if any(~found)
            throw( exception.Base('VAR:GROUP_NOT_INPUT_DATA', 'error'), ...
                this.GroupNames(~found) );
        end
    end%


    function clipRange( )
        % Clip the range if user specified -Inf or Inf at either range end. Do not
        % use X to determine the start and end of the range because this could
        % result in unncessary removal of lags of endogenous variables.
        if isFirstInf
            sample = ~any( any(isnan(y{1}), 3), 1 );
            first = find(sample, 1);
            y{iGrp} = y{iGrp}(:, first:end, :);
            x{iGrp} = x{iGrp}(:, first:end, :);
            extdRange = extdRange(first:end);
        end
        if isLastInf
            sample = ~any( any(isnan(y{iGrp}), 3), 1 );
            last = find(sample, 1, 'last');
            y{iGrp} = y{iGrp}(:, 1:last, :);
            x{iGrp} = x{iGrp}(:, 1:last, :);
            extdRange = extdRange(1:last);
        end
    end%
end%
