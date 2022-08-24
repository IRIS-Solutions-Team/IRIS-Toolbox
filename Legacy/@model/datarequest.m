function varargout = datarequest(req, this, data, range, whichSet, expandMethod)

%#ok<*CTCH>
%#ok<*VUNUS>

try, whichSet; catch, whichSet = ':'; end %#ok<NOCOM>
try, expandMethod; catch, expandMethod = 'RepeatLast'; end %#ok<NOCOM>

%--------------------------------------------------------------------------

[ny, nxi, nb, nf, ~, ~, nz] = sizeSolution(this);
nv = length(this);
range = double(range);
range = range(1) : range(end);
numPeriods = numel(range);

if isempty(data)
    data = struct( );
end

dMean = [ ];
dMse = [ ];

if validate.databank(data) && isfield(data, 'mean') && validate.databank(data.mean)
    % Databank with `.mean` and possibly also `.mse`
        dMean = data.mean;
        if isfield(data, 'mse') && isa(data.mse, 'Series')
            dMse = data.mse;
        end
elseif validate.databank(data)
    % Plain database
    dMean = data;
else
    throw( exception.Base('Model:UnknownInputData', 'error') );
end

% Warning structure for `db2array`.
warn = struct( );
warn.NotFound = false;
warn.SizeMismatch = true;
warn.FreqMismatch = true;
warn.NonTseries = true;
warn.NoRangeFound = true;

% Requests with a star `*` throw a warning if one or more series is not
% found in the input database.
try %#ok<TRYNC>
    if isequal(req(end), '*')
        warn.NotFound = true;
        req(end) = '';
    end
end

switch lower(req)
    case 'init'
        % Initial condition for the mean and MSE of Alpha.
        if nargout<4
            [xbInitMean, lsNanInitMean] = assembleXbInit( );
            xbInitMse = [ ];
            alpInitMean = convertXbInit2AlpInit( );
            varargout{1} = alpInitMean;
            varargout{2} = xbInitMean;
            varargout{3} = lsNanInitMean;
        else
            [xbInitMean, lsNanInitMean, xbInitMse, lsNanInitMse] = assembleXbInit( );
            [alpInitMean, alpInitMse] = convertXbInit2AlpInit( );
            varargout{1} = alpInitMean;
            varargout{2} = xbInitMean;
            varargout{3} = lsNanInitMean;
            varargout{4} = alpInitMse;
            varargout{5} = xbInitMse;
            varargout{6} = lsNanInitMse;
        end
    case 'xbinit'
        % Initial condition for the mean and MSE of X.
        [varargout{1:nargout}] = assembleXbInit( );
    case 'xinit'
        varargout{1} = assembleXData(range(1)-1);
    case 'y'
        % Measurement variables.
        y = assembleYData( );
        varargout{1} = y;
    case {'yg', 'tyg', 'fyg'}
        % Measurement variables, and exogenous variables for deterministic trends.
        % In request, `t` means time domain, `f` means frequency domain.
        if nz>0
            y = assembleZData( );
        else
            y = assembleYData( );
        end
        if strncmpi(req, 'f', 1)
            y = permute(y, [2, 1, 3]);
            y = fft(y);
            y = ipermute(y, [2, 1, 3]);
        end
        g = assembleGData( );
        nYData = size(y, 3);
        if size(g, 3) == 1 && size(g, 3)<nYData
            g = g(:, :, ones(1, nYData));
        end
        varargout{1} = [y; g];
    case 'e'
        varargout{1} = assembleEData( );
    case 'x'
        % Current dates of transition variables.
        varargout{1} = assembleXData(range);
    case 'yxe'
        data = {assembleYData( ), assembleXData(range), assembleEData( )};
        numDataSets = max([size(data{1}, 3), size(data{2}, 3), size(data{3}, 3)]);
        % Make the size of all data arrays equal in 3rd dimension.
        if size(data{1}, 3)<numDataSets
            data{1} = cat(3, data{1}, ...
                data{1}(:, :, end*ones(1, numDataSets-size(data{1}, 3))));
        end
        if size(data{2}, 3)<numDataSets
            data{2} = cat(3, data{2}, ...
                data{2}(:, :, end*ones(1, numDataSets-size(data{2}, 3))));
        end
        if size(data{3}, 3)<numDataSets
            data{3} = cat(3, data{3}, ...
                data{3}(:, :, end*ones(1, numDataSets-size(data{3}, 3))));
        end
        varargout = data;
    case 'g'
        % Exogenous variables for deterministic trends.
        varargout{1} = assembleGData( );
    case 'alpha'
        varargout{1} = assembleAlphaData( );
end

if ~all(strcmpi(whichSet, ':')) && ~isequal(whichSet, Inf)
    for i = 1 : length(varargout)
        varargout{i} = varargout{i}(:, :, whichSet);
    end
end

return


    function [xbInitMean, lsNanInitMean, xbInitMse, lsNanInitMse] ...
            = assembleXbInit( )
        xbInitMean = nan(nb, 1, nv);
        xbInitMse = [ ];
        % Xf Mean.
        if ~isempty(dMean)
            realId = real(this.Vector.Solution{2}(nf+1:end));
            imagId = imag(this.Vector.Solution{2}(nf+1:end));
            sw = struct( );
            sw.LagOrLead = imagId;
            sw.IxLog = this.Quantity.IxLog(realId);
            sw.Warn = warn;
            sw.ExpandMethod = expandMethod;
            xbInitMean = db2array(dMean, this.Quantity.Name(realId), range(1)-1, sw);
            xbInitMean = permute(xbInitMean, [2, 1, 3]);
        end
        % Xf MSE.
        if nargout>=3 && ~isempty(dMse)
            tempDate = dater.plus(range(1), -1);
            xbInitMse = getDataFromTo(dMse, tempDate);
            xbInitMse = ipermute(xbInitMse, [3, 2, 1, 4]);
        end
        % Detect NaN init conditions.
        ixNanInitMean = false(nb, 1);
        ixNanInitMse = false(nb, 1);
        for ii = 1 : size(xbInitMean, 3)
            ixRequired = this.Variant.IxInit(:, :, min(ii, end));
            ixRequired = ixRequired(:);
            ixNanInitMean = ixNanInitMean | ...
                (isnan(xbInitMean(:, 1, ii)) & ixRequired);
            if ~isempty(xbInitMse)
                ixNanInitMse = ixNanInitMse | ...
                    (any(isnan(xbInitMse(:, :, ii)), 2) & ixRequired);
            end
        end
        % Report NaN init conditions in mean.
        lsNanInitMean = { };
        if any(ixNanInitMean)
            id = this.Vector.Solution{2}(nf+1:end);
            lsNanInitMean = printSolutionVector(this, id(ixNanInitMean)-1i);
        end
        % Report NaN init conditions in MSE.
        lsNanInitMse = { };
        if any(ixNanInitMse)
            id = this.Vector.Solution{2}(nf+1:end);
            lsNanInitMse = printSolutionVector(this, id(ixNanInitMse)-1i);
        end
    end


% Get initial conditions for xb and alpha.
% Those that are not required are set to `NaN` in `xInitMean`, and
% to 0 when computing `aInitMean`.
    function [alpInitMean, alpInitMse] = convertXbInit2AlpInit( )
        % Transform Mean[Xb] to Mean[Alpha].
        numDataSets = size(xbInitMean, 3);
        if numDataSets<nv
            xbInitMean(:, 1, end+1:nv) = ...
                xbInitMean(:, 1, end*ones(1, nv-numDataSets));
            numDataSets = nv;
        end
        alpInitMean = xbInitMean;
        for ii = 1 : numDataSets
            U = this.Variant.FirstOrderSolution{7}(:, :, min(ii, end));
            if all(~isnan(U(:)))
                ixRequired = this.Variant.IxInit(:, :, min(ii, end));
                inx = isnan(xbInitMean(:, 1, ii)) & ~ixRequired(:);
                alpInitMean(inx, 1, ii) = 0;
                alpInitMean(:, 1, ii) = U \ alpInitMean(:, 1, ii);
            else
                alpInitMean(:, 1, ii) = NaN;
            end
        end
        % Transform MSE[Xb] to MSE[Alpha].
        if nargout<2 || isempty(xbInitMse)
            alpInitMse = xbInitMse;
            return
        end
        numDataSets = size(xbInitMse, 4);
        if numDataSets<nv
            xbInitMse(:, :, 1, end+1:nv) = ...
                xbInitMse(:, :, 1, end*ones(1, nv-numDataSets));
            numDataSets = nv;
        end
        alpInitMse = xbInitMse;
        for ii = 1 : numDataSets
            U = this.Variant.FirstOrderSolution{7}(:, :, min(ii, end));
            if all(~isnan(U(:)))
                alpInitMse(:, :, 1, ii) = U \ alpInitMse(:, :, 1, ii);
                alpInitMse(:, :, 1, ii) = alpInitMse(:, :, 1, ii) / U.';
            else
                alpInitMse(:, :, 1, ii) = NaN;
            end
        end
    end


    function Y = assembleYData( )
        % Measurement variables.
        if ~isempty(dMean)
            ixy = this.Quantity.Type==1;
            sw = struct( );
            sw.LagOrLead = [ ];
            sw.IxLog = this.Quantity.IxLog(ixy);
            sw.Warn = warn;
            sw.ExpandMethod = expandMethod;
            Y = db2array(dMean, this.Quantity.Name(ixy), range, sw);
            Y = permute(Y, [2, 1, 3]);
        end
    end


    function z = assembleZData( )
        % Transition variables marked for measurement
        if ~isempty(dMean)
            ixz = this.Quantity.IxObserved;
            sw = struct( );
            sw.LagOrLead = [ ];
            sw.IxLog = this.Quantity.IxLog(ixz);
            sw.Warn = warn;
            sw.ExpandMethod = expandMethod;
            z = db2array(dMean, this.Quantity.Name(ixz), range, sw);
            z = permute(z, [2, 1, 3]);
        end
    end%


    function E = assembleEData( )
        if ~isempty(dMean)
            ixe = this.Quantity.Type==31 ...
                | this.Quantity.Type==32;
            sw = struct( );
            sw.LagOrLead = [ ];
            sw.IxLog = [ ];
            sw.Warn = warn;
            sw.ExpandMethod = expandMethod;
            E = db2array(dMean, this.Quantity.Name(ixe), range, sw);
            E = permute(E, [2, 1, 3]);
        end
        eReal = real(E);
        eImag = imag(E);
        eReal(isnan(eReal)) = 0;
        eImag(isnan(eImag)) = 0;
        E = eReal + 1i*eImag;
    end


    function g = assembleGData( )
        % Here we assume exogenous names are a continous block in Quantity.Name.
        ixg = this.Quantity.Type==5;
        ng = sum(ixg);
        posg = find(ixg);
        ixq = strcmp(this.Quantity.Name, model.Quantity.RESERVED_NAME_TTREND);
        ixgxq = ixg & ~ixq; % Exogenous variables except ttrend
        ngxq = sum(ixgxq);
        posq = find(ixq) - min(posg) + 1;
        posgxq = find(ixgxq) - min(posg) + 1;
        ttrend = dat2ttrend(range, this);
        if any(ixgxq)
            if ~isempty(dMean)
                lsgxq = this.Quantity.Name(ixgxq);
                sw = struct( );
                sw.LagOrLead = [ ];
                sw.IxLog = [ ];
                sw.Warn = warn;
                sw.ExpandMethod = expandMethod;
                gxq = db2array(dMean, lsgxq, range, sw);
                gxq = permute(gxq, [2, 1, 3]);
            else
                gxq = nan(ngxq, numPeriods);
            end
            size3d = size(gxq, 3);
            g = nan(ng, numPeriods, size3d);
            g(posgxq, :, :) = gxq;
            g(posq, :, :) = repmat(ttrend, 1, 1, size3d);
        else
            g = ttrend;
        end
    end


    function X = assembleXData(range)
        % Get current dates of transition variables.
        % Set lags and leads to NaN.
        realId = real(this.Vector.Solution{2});
        imagId = imag(this.Vector.Solution{2});
        currentInx = imagId==0;
        if ~isempty(dMean)
            realId = realId(currentInx);
            imagId = imagId(currentInx);
            sw = struct( );
            sw.LagOrLead = imagId;
            sw.IxLog = this.Quantity.IxLog(realId);
            sw.Warn = warn;
            sw.ExpandMethod = expandMethod;
            x = db2array(dMean, this.Quantity.Name(realId), range, sw);
            x = permute(x, [2, 1, 3]);
            X = nan(nxi, size(x, 2), size(x, 3));
            X(currentInx, :, :) = x;
        end
    end


    function A = assembleAlphaData( )
        if ~isempty(dMean)
            realId = real(this.Vector.Solution{2});
            imagId = imag(this.Vector.Solution{2});
            realId = realId(nf+1:end);
            imagId = imagId(nf+1:end);
            sw = struct( );
            sw.LagOrLead = imagId;
            sw.IxLog = this.Quantity.IxLog(realId);
            sw.Warn = warn;
            sw.ExpandMethod = expandMethod;
            A = db2array(dMean, this.Quantity.Name(realId), range, sw);
            A = permute(A, [2, 1, 3]);
        end
        numDataSets = size(A, 3);
        if numDataSets<nv
            A(:, :, end+1:nv) = A(:, :, end*ones(1, nv-numDataSets));
            numDataSets = nv;
        end
        for ii = 1 : numDataSets
            U = this.Variant.FirstOrderSolution{7}(:, :, min(ii, end));
            if all(~isnan(U(:)))
                A(:, :, ii) = U\A(:, :, ii);
            else
                A(:, :, ii) = NaN;
            end
        end
    end
end
