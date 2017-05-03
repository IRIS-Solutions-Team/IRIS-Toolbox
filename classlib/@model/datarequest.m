function varargout = datarequest(req, this, data, range, whichSet, expandMethod)
% datarequest  Request model specific data from database.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%#ok<*CTCH>
%#ok<*VUNUS>

TYPE = @int8;

try, whichSet; catch, whichSet = ':'; end %#ok<NOCOM>
try, expandMethod; catch, expandMethod = 'RepeatLast'; end %#ok<NOCOM>

%--------------------------------------------------------------------------

[~, nxx, nb, nf] = sizeOfSolution(this.Vector);
nAlt = length(this);
range = range(1) : range(end);
nPer = length(range);

if isempty(data)
    data = struct( );
end

dMean = [ ];
dMse = [ ];

if isstruct(data) && isfield(data, 'mean') && isstruct(data.mean)
    % Struct with `.mean` and possibly also `.mse`.
        dMean = data.mean;
        if isfield(data, 'mse') && isa(data.mse, 'tseries')
            dMse = data.mse;
        end
elseif isstruct(data)
    % Plain database.
    dMean = data;
else
    throw( ...
        exception.Base('Model:UnknownInputData', 'error') ...
        );
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
            [xbInitMean, ixNanInitMean, xbInitMse, ixNanInitMse] = assembleXbInit( );
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
        y = getYData( );
        varargout{1} = y;
    case {'yg', 'tyg', 'fyg'}
        % Measurement variables, and exogenous variables for deterministic trends.
        % In request, `t` means time domain, `f` means frequency domain.
        y = getYData( );
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
        varargout{1} = [y;g];
    case 'e'
        varargout{1} = assembleEData( );
    case 'x'
        % Current dates of transition variables.
        varargout{1} = assembleXData(range);
    case 'yxe'
        data = {getYData( ), assembleXData(range), assembleEData( )};
        nData = max([size(data{1}, 3), size(data{2}, 3), size(data{3}, 3)]);
        % Make the size of all data arrays equal in 3rd dimension.
        if size(data{1}, 3)<nData
            data{1} = cat(3, data{1}, ...
                data{1}(:, :, end*ones(1, nData-size(data{1}, 3))));
        end
        if size(data{2}, 3)<nData
            data{2} = cat(3, data{2}, ...
                data{2}(:, :, end*ones(1, nData-size(data{2}, 3))));
        end
        if size(data{3}, 3)<nData
            data{3} = cat(3, data{3}, ...
                data{3}(:, :, end*ones(1, nData-size(data{3}, 3))));
        end
        varargout = data;
    case 'g'
        % Exogenous variables for deterministic trends.
        varargout{1} = assembleGData( );
    case 'alpha'
        varargout{1} = assembleAlphaData( );
end

if ~isequal(whichSet, ':') && ~isequal(whichSet, Inf)
    for i = 1 : length(varargout)
        varargout{i} = varargout{i}(:, :, whichSet);
    end
end

return
    
    
    
    
    function [xbInitMean, lsNanInitMean, xbInitMse, lsNanInitMse] ...
            = assembleXbInit( )
        xbInitMean = nan(nb, 1, nAlt);
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
        if nargout >= 3 && ~isempty(dMse)
            xbInitMse = rangedata(dMse, range(1)-1);
            xbInitMse = ipermute(xbInitMse, [3, 2, 1, 4]);
        end
        % Detect NaN init conditions.
        ixNanInitMean = false(nb, 1);
        ixNanInitMse = false(nb, 1);
        for ii = 1 : size(xbInitMean, 3)
            ixRequired = this.Variant{min(ii, end)}.IxInit;
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
            ixNanInitMse = printSolutionVector(this, id(ixNanInitMse)-1i);
        end
    end 




% Get initial conditions for xb and alpha.
% Those that are not required are set to `NaN` in `xInitMean, and
% to 0 when computing `aInitMean`.
    function [alpInitMean, alpInitMse] = convertXbInit2AlpInit( )
        % Transform Mean[Xb] to Mean[Alpha].
        nData = size(xbInitMean, 3);
        if nData<nAlt
            xbInitMean(:, 1, end+1:nAlt) = ...
                xbInitMean(:, 1, end*ones(1, nAlt-nData));
            nData = nAlt;
        end
        alpInitMean = xbInitMean;
        for iiData = 1 : nData
            U = this.solution{7}(:, :, min(iiData, end));
            if all(~isnan(U(:)))
                ixRequired = this.Variant{min(iiData, end)}.IxInit;
                inx = isnan(xbInitMean(:, 1, iiData)) & ~ixRequired(:);
                alpInitMean(inx, 1, iiData) = 0;
                alpInitMean(:, 1, iiData) = U \ alpInitMean(:, 1, iiData);
            else
                alpInitMean(:, 1, iiData) = NaN;
            end
        end
        % Transform MSE[Xb] to MSE[Alpha].
        if nargout<2 || isempty(xbInitMse)
            alpInitMse = xbInitMse;
            return
        end
        nData = size(xbInitMse, 4);
        if nData<nAlt
            xbInitMse(:, :, 1, end+1:nAlt) = ...
                xbInitMse(:, :, 1, end*ones(1, nAlt-nData));
            nData = nAlt;
        end
        alpInitMse = xbInitMse;
        for iiData = 1 : nData
            U = this.solution{7}(:, :, min(iiData, end));
            if all(~isnan(U(:)))
                alpInitMse(:, :, 1, iiData) = U \ alpInitMse(:, :, 1, iiData);
                alpInitMse(:, :, 1, iiData) = alpInitMse(:, :, 1, iiData) / U.';
            else
                alpInitMse(:, :, 1, iiData) = NaN;
            end
        end
    end




    function Y = getYData( )
        if ~isempty(dMean)
            ixy = this.Quantity.Type==TYPE(1);
            sw = struct( );
            sw.LagOrLead = [ ];
            sw.IxLog = this.Quantity.IxLog(ixy);
            sw.Warn = warn;
            sw.ExpandMethod = expandMethod;
            Y = db2array(dMean, this.Quantity.Name(ixy), range, sw);
            Y = permute(Y, [2, 1, 3]);
        end
    end



    
    function E = assembleEData( )
        if ~isempty(dMean)
            ixe = this.Quantity.Type==TYPE(31) ...
                | this.Quantity.Type==TYPE(32);
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
        ixg = this.Quantity.Type==TYPE(5);
        ng = sum(ixg);
        posg = find(ixg);
        ixq = strcmp(this.Quantity.Name, model.RESERVED_NAME_TTREND);
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
                gxq = nan(ngxq, nPer);
            end
            size3d = size(gxq, 3); 
            g = nan(ng, nPer, size3d);
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
            X = nan(nxx, size(x, 2), size(x, 3));
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
        nData = size(A, 3);
        if nData<nAlt
            A(:, :, end+1:nAlt) = A(:, :, end*ones(1, nAlt-nData));
            nData = nAlt;
        end
        for ii = 1 : nData
            U = this.solution{7}(:, :, min(ii, end));
            if all(~isnan(U(:)))
                A(:, :, ii) = U\A(:, :, ii);
            else
                A(:, :, ii) = NaN;
            end
        end
    end
end
