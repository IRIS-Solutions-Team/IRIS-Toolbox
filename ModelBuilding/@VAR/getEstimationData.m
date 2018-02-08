function [y, x, extendedRange] = getEstimationData(this, d, range, p, startDate)
% getEstimationData  Retrieve input data and determine extended range 
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2018 IRIS Solutions Team

%--------------------------------------------------------------------------

% Get extended range including pre-sample
if strcmpi(startDate, 'Presample')
    % User entered range including pre-sample
    extendedRange = range;
elseif strncmpi(startDate, 'Fit', 3)
    % User entered fit range excluding pre-sample
    if isinf(range(1))
        extendedRange = range;
    else
        extendedRange = range(1)-p : range(end);
    end
end

isPanel = ispanel(this);
ky = length(this.NamesEndogenous);
kx = length(this.NamesExogenous);
extendedRange = extendedRange(:).';
nGrp = max(1, length(this.GroupNames));
y = cell(1, nGrp);
x = cell(1, nGrp);
lsyx = [this.NamesEndogenous, this.NamesExogenous];

sw = struct( );
sw.BaseYear = this.BaseYear;

if isPanel
    % Check if all group names are contained withing the input database.
    checkGroupNames( );
    if any(isinf(extendedRange(:)))
        throw( exception.Base('VAR:CANNOT_INF_RANGE_IN_PANEL', 'error') );
    end
end
isFirstInf = isinf(extendedRange(1));
isLastInf = isinf(extendedRange(end));

for iGrp = 1 : nGrp
    if ~isPanel
        % Capture range on output to deal with -Inf, Inf.
        [yx, ~, extendedRange] = db2array(d, lsyx, extendedRange, sw);
    else
        name = this.GroupNames{iGrp};
        yx = db2array(d.(name), lsyx, extendedRange, sw);
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


    function checkGroupNames( )
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
            extendedRange = extendedRange(first:end);
        end
        if isLastInf
            sample = ~any( any(isnan(y{iGrp}), 3), 1 );
            last = find(sample, 1, 'last');
            y{iGrp} = y{iGrp}(:, 1:last, :);
            x{iGrp} = x{iGrp}(:, 1:last, :);
            extendedRange = extendedRange(1:last);
        end
    end
end
