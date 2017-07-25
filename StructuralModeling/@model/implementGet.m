function [answ, flag, query] = implementGet(this, query, varargin)
% implementGet  Implement get method for model objects.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

EIGEN_TOLERANCE = this.Tolerance.Eigen;
TYPE = @int8;

%--------------------------------------------------------------------------

[answ, flag, query] = implementGet@shared.UserDataContainer(this, query, varargin{:});
if flag
    return
end

[answ, flag, query] = implementGet@shared.Exported(this, query, varargin{:});
if flag
    return
end

[answ, flag, query] = implementGet@shared.UserDataContainer(this, query, varargin{:});
if flag
    return
end

[answ, flag, query] = implementGet(this.Link, this.Quantity, query, varargin{:});
if flag
    return
end

[answ, flag, query] = implementGet(this.Quantity, query, varargin{:});
if flag
    return
end

[answ, flag, query] = implementGet(this.Equation, this.Quantity, this.Pairing, query, varargin{:});
if flag
    return
end

[answ, flag, query] = implementGet(this.Gradient, query, varargin{:});
if flag
    return
end

[answ, flag, query] = model.Pairing.implementGet(this.Pairing, this.Quantity, query, varargin{:});
if flag
    return
end

[answ, flag, query] = implementGet(this.Behavior, query, varargin{:});
if flag
    return
end


answ = [ ];
flag = true;

ssLevel = [ ];
ssGrowth = [ ];
dtLevel = [ ];
dtGrowth = [ ];
ssDtLevel = [ ];
ssDtGrowth = [ ];

% Query relates to steady state.
steadyList = { ...
    'ss', 'steady', 'sslevel', 'level', 'ssgrowth', 'growth', ...
    'steadylevel', 'steadygrowth', ...
    };
dtrendList = { ...
    'dt', 'dtlevel', 'dtgrowth', ...
    'ss+dt', 'sslevel+dtlevel', 'ssgrowth+dtgrowth', ...
    };
if any(strcmpi(query, dtrendList))
    [ssLevel, ssGrowth, dtLevel, dtGrowth, ssDtLevel, ssDtGrowth] = getSteady(this);
elseif any(strcmpi(query, steadyList))
    [ssLevel, ssGrowth] = getSteady(this);
end

[~, ~, nb, nf] = sizeOfSolution(this.Vector);
ixe = this.Quantity.Type==TYPE(31) ...
    | this.Quantity.Type==TYPE(32);
ne = sum(ixe);
nAlt = length(this);

cell2DbaseFunc = @(X) cell2struct( ...
    num2cell(permute(X, [2, 3, 1]), 2), ...
    this.Quantity.Name(:), 1);

needsChkSolution = false;
needsAddParams = false;

switch lower(query)
    
    case 'incidence'
        answ = struct( ...
            'Dynamic', implementGet(this.Incidence.Dynamic, 'Incidence'), ...
            'Steady',  implementGet(this.Incidence.Steady, 'Incidence') ...
            );
        
        
    
        
    case 'file'
        answ = this.FileName;

        
        
        
    case 'param'
        dbPar = implementGet(this, 'PlainParam');
        dbStd = implementGet(this, 'Std');
        dbCorr = implementGet(this, 'NonzeroCorr');
        answ = dbmerge(dbPar, dbStd, dbCorr);
          
        
        
        
    case {'plainparam'}
        ixp = this.Quantity.Type==TYPE(4);
        answ = struct( );
        for i = find(ixp)
            name = this.Quantity.Name{i};
            value = model.Variant.getQuantity(this.Variant, i, ':');
            answ.(name) = permute(value, [2, 3, 1]);
        end
        
        
        
        
    case 'std'
        lsStd = getStdName(this.Quantity);
        vecStd = model.Variant.getAllStd(this.Variant, ':');
        answ = struct( );
        for i = 1 : length(lsStd)
            answ.(lsStd{i}) = permute(vecStd(1, i, :), [2, 3, 1]);
        end
        
        
        
        
    case {'corr', 'nonzerocorr'}
        isNonzeroOnly = strcmpi(query, 'nonzeroCorr');
        lsCorr = getCorrName(this.Quantity);
        vecCorr = model.Variant.getAllCorr(this.Variant, ':');
        ixCorrAllowed = this.Quantity.IxStdCorrAllowed(ne+1:end);
        lsCorr = lsCorr(ixCorrAllowed);
        vecCorr = vecCorr(ixCorrAllowed);
        if isNonzeroOnly
            posRemove = find(all(vecCorr==0, 3));
            vecCorr(:, posRemove, :) = [ ];
            lsCorr(posRemove) = [ ];
        end
        answ = struct( );
        for i = 1 : length(lsCorr)
            answ.(lsCorr{i}) = permute(vecCorr(1, i, :), [2, 3, 1]);
        end

        
        
        
    case 'stdcorr'
        dbStd = implementGet(this, 'Std');
        dbCorr = implementGet(this, 'Corr');
        answ = dbmerge(dbStd, dbCorr);

        
        
        
    case 'exogenous'
        ixg = this.Quantity.Type==TYPE(5);
        answ = struct( );
        for i = find(ixg)
            name = this.Quantity.Name{i};
            value = model.Variant.getQuantity(this.Variant, i, ':');
            answ.(name) = permute(value, [2, 3, 1]);
        end        
        
        
        
        
    case 'stdlist'
        answ = getStdName(this.Quantity);
        
        
        
        
    case 'corrlist'
        answ = getCorrName(this.Quantity);
        
        
        
        
    case 'stdcorrlist'
        lsStd = implementGet(this, 'StdList');
        lsCorr = implementGet(this, 'CorrList');
        answ = [lsStd, lsCorr];
        
        
        
        
    case {'log', 'islog'}
        ixType = this.Quantity.Type~=TYPE(4);
        answ = cell2struct( ...
            num2cell(this.Quantity.IxLog(ixType)), ...
            this.Quantity.Name(ixType), 2 ...
            );
        
        
        
        
    case {'loglist'}
        answ = this.Quantity.Name(this.Quantity.IxLog);
        
        
        
        
    case {'nonloglist'}
        answ = this.Quantity.Name(~this.Quantity.IxLog);
        
        
        
        
    case {'covmat', 'omega'}
        answ = omega(this);
        
        
        
        
    case {'stdvec'}
        x = model.Variant.getAllStd(this.Variant, ':');
        answ = permute(x, [2, 3, 1]);
        
        
        
        
    case {'stdcorrvec'}
        x = model.Variant.getStdCorr(this.Variant, ':', ':');
        answ = permute(x, [2, 3, 1]);
        
        
        
        
    case {'nalt'}
        answ = nAlt;
        
        
        
        
    case {'nametype'}
        answ = this.Quantity.Type;

        
        
        
    case 'build'
        answ = this.Build;

        
        
        
    case {'preparser', 'preparsercontrol', 'pset'}
        answ = this.PreparserControl;

        
        
        
    case {'ss', 'steady'}
        answ = cell2DbaseFunc(ssLevel+1i*ssGrowth);
        % addParams = true;
        
        
        
        
    case {'sslevel', 'steadylevel'}
        answ = cell2DbaseFunc(ssLevel);
        needsAddParams = true;
        
        
        
        
    case {'ssgrowth', 'steadygrowth'}
        answ = cell2DbaseFunc(ssGrowth);
        needsAddParams = true;
        
        
        
        
    case 'dt'
        answ = cell2DbaseFunc(dtLevel+1i*dtGrowth);
        needsAddParams = true;
        
        
        
        
    case 'dtlevel'
        answ = cell2DbaseFunc(dtLevel);
        needsAddParams = true;
        
    case 'dtgrowth'
        ixNanSolution = this.Quantity.Type==TYPE(1);
        answ = cell2DbaseFunc(dtGrowth);
        needsAddParams = true;
        
    case 'ss+dt'
        answ = cell2DbaseFunc(ssDtLevel+1i*ssDtGrowth);
        needsAddParams = true;
        
    case 'sslevel+dtlevel'
        answ = cell2DbaseFunc(ssDtLevel);
        needsAddParams = true;
        
    case 'ssgrowth+dtgrowth'
        answ = cell2DbaseFunc(ssDtGrowth);
        needsAddParams = true;
        
    case {'eig', 'eigval', 'roots'}
        answ = eig(this);
        
    case 'rlist'
        answ = implementGet(this.Reporting, 'list');
                
    case 'reqtn'
        answ = implementGet(this.Reporting, 'eqtn');
        
    case 'rlabel'
        answ = implementGet(this.Reporting, 'label');
        
    case {'yvector', 'yvec'}
        answ = printSolutionVector(this, 'y');
        answ = answ.';
        
    case {'xvector', 'xvec'}
        answ = printSolutionVector(this, 'x');
        answ = answ.';
        
    case {'xfvector', 'xfvec'}
        answ = printSolutionVector(this, 'x');
        answ = answ(1:nf);
        answ = answ.';
        
    case {'xbvector', 'xbvec'}
        answ = printSolutionVector(this, 'x');
        answ = answ(nf+1:end);
        answ = answ.';
        
    case {'evector', 'evec'}
        answ = printSolutionVector(this, 'e');
        answ = answ.';
        
    case {'ylog', 'xlog', 'elog', 'plog', 'glog'}
        switch query(1)
            case 'y'
                ixType = this.Quantity.Type==TYPE(1);
            case 'x'
                ixType = this.Quantity.Type==TYPE(2);
            case 'e'
                ixType = this.Quantity.Type==TYPE(31) ...
                    | this.Quantity.Type==TYPE(32);
            case 'p'
                ixType = this.Quantity.Type==TYPE(4);
            case 'g'
                ixType = this.Quantity.Type==TYPE(5);
            otherwise
                ixType = false(1, length(this.Quantity));
        end        
        answ = this.Quantity.IxLog(ixType);
        

    
    
    case {'eylist', 'exlist'}
        switch query(2)
            case 'y'
                ixType = this.Quantity.Type==TYPE(31);
            case 'x'
                ixType = this.Quantity.Type==TYPE(32);
        end
        answ = this.Quantity.Name(ixType);
        
        
        
        
    case {'diffuse', 'nonstationary', 'isnonstationary', 'stationary', 'isstationary' ...
            'stationarylist', 'nonstationarylist'}
        getStationary(query);

        
        
        
    case 'maxlag'
        maxLagDynamic = getMaxShift(this.Incidence.Dynamic);
        maxLagSteady = getMaxShift(this.Incidence.Steady);
        answ = min(maxLagDynamic, maxLagSteady);
        
        
        
        
    case 'maxlead'
        [~, maxLeadDynamic] = getMaxShift(this.Incidence.Dynamic);
        [~, maxLeadSteady] = getMaxShift(this.Incidence.Steady);
        answ = max(maxLeadDynamic, maxLeadSteady);
        
        
        
        
    case {'icond', 'initcond', 'required', 'requiredinitcond'}
        % True initial conditions required at least in one parameter variant.
        vecXb = this.Vector.Solution{2}(nf+1:end);
        ixInit = model.Variant.get(this.Variant, 'IxInit', ':');
        ixInit = any(ixInit, 3);
        answ = printSolutionVector(this, vecXb(ixInit)-1i);
        
        
        
        
    case {'forward'}
        answ = size(this.solution{2}, 2)/ne - 1;
        needsChkSolution = true;
        
        
        
        
    case {'stableroots', 'unitroots', 'unstableroots'}
        eig_ = model.Variant.get(this.Variant, 'Eigen', ':');
        stability = model.Variant.get(this.Variant, 'Stability', ':');
        switch query
            case 'stableroots'
                ixSelect = stability==TYPE(0);
            case 'unstableroots'
                ixSelect = stability==TYPE(2);
            case 'unitroots'
                ixSelect = stability==TYPE(1);
        end
        answ = nan(size(eig_));
        for iAlt = 1 : nAlt
            n = sum(ixSelect(1, :, iAlt));
            answ(1, 1:n, iAlt) = eig_(1, ixSelect(1, :, iAlt), iAlt);
        end
        answ(:, all(isnan(answ), 3), :) = [ ];
        
        
        
        
    case 'epsilon'
        answ = this.Tolerance.DiffStep;
        
        
        
        
    case 'userdata'
        answ = userdata(this);
        
        
        
        
    % Database of autoexogenise definitions d.variable = 'shock';
    case {'autoexogenise', 'autoexogenised', 'autoexogenize', 'autoexogenized'}
        answ = autoexogenise(this);
        
        
        
        
    case {'autoexog'}
        answ = autoexog(this);

        
        
        
    case {'activeshocks', 'inactiveshocks'}
        answ = cell(1, nAlt);
        for iAlt = 1 : nAlt
            lsShock = this.Quantity.Name(ixe);
            vecStd = this.Variant{iAlt}.StdCorr(1, 1:ne);
            if query(1)=='a'
                lsShock(vecStd==0) = [ ];
            else
                lsShock(vecStd~=0) = [ ];
            end
        end
        answ{iAlt} = lsShock;
        
    case {'reporting', 'rpteq'}
        answ = this.Reporting;
        
        
        
        
    case 'nx'
        answ = length(this.Vector.Solution{2});
        
        
        
        
    case 'nb'
        answ = size(this.solution{7}, 1);
        
        
        
        
    case 'nf'
        answ = length(this.Vector.Solution{2}) - size(this.solution{7}, 1);
        
        
        
        
    case 'ny'
        answ = sum(this.Quantity.Type==TYPE(1));
        
        
        
        
    case 'ng'
        answ = sum(this.Quantity.Type==TYPE(5));
        
        
        
        
    case 'ne'
        answ = sum(this.Quantity.Type==TYPE(31) | this.Quantity.Type==TYPE(32));
        



    case {'islinear', 'linear'}
        answ = this.IsLinear;



        
    case {'lastsyst', 'lastsystem'}
        answ = this.LastSystem;
        



    otherwise
        flag = false;
        
end

if needsChkSolution
    % Report solution(s) not available.
    [solutionFlag, ixNanSolution] = isnan(this, 'solution');
    if solutionFlag
        utils.warning('model:implementGet', ...
            'Solution(s) not available %s.', ...
            exception.Base.alt2str(ixNanSolution) );
    end
end

% Add parameters, std devs and non-zero cross-corrs.
if needsAddParams
    answ = addparam(this, answ);
end

return




    function getStationary(query)
        needsChkSolution = true;
        if strncmpi(query, 'is', 2)
            query(1:2) = '';
        end
        vecXb = [this.Vector.Solution{1:2}];
        t0 = imag(vecXb)==0;
        name = this.Quantity.Name( real(vecXb(t0)) );
        [~, ixNanSolution] = isnan(this, 'solution');
        status = nan([sum(t0), nAlt]);
        for iiAlt = find(~ixNanSolution)
            ixUnit = this.Variant{iiAlt}.Stability(1:nb)==TYPE(1);
            dy = any(abs(this.solution{4}(:, ixUnit, iiAlt))>EIGEN_TOLERANCE, 2).';
            df = any(abs(this.solution{1}(1:nf, ixUnit, iiAlt))>EIGEN_TOLERANCE, 2).';
            db = any(abs(this.solution{7}(:, ixUnit, iiAlt))>EIGEN_TOLERANCE, 2).';
            d = [dy, df, db];
            
            if strncmp(query, 's', 1)
                % Stationary.
                status(:, iiAlt) = double(~d(t0)).';
            else
                % Non-stationary.
                status(:, iiAlt) = double(d(t0)).';
            end
        end
        try %#ok<TRYNC>
            status = logical(status);
        end
        if ~isempty(strfind(query, 'list'))
            % List.
            if nAlt==1
                answ = name(status==true | status==1);
                answ = answ(:)';
            else
                answ = cell([1, nAlt]);
                for ii = 1 : nAlt
                    answ{ii} = name(status(:, ii)==true | status(:, ii)==1);
                    answ{ii} = answ{ii}(:).';
                end
            end
        else
            % Database.
            answ = cell2struct( num2cell(status, 2), name(:), 1 );
        end
    end
end




function [ssLevel, ssGrowth, dtLevel, dtGrowth, ssDtLevel, ssDtGrowth] ...
    = getSteady(this)
TYPE = @int8;

nQty = length(this.Quantity);
nAlt = length(this.Variant);
ixy = this.Quantity.Type==TYPE(1);
ixLog = this.Quantity.IxLog;

% Steady states.
ss = model.Variant.getQuantity(this.Variant, ':', ':');
ssLevel = real(ss);
ssGrowth = imag(ss);

% Fix missing (=zero) growth in steady states of log variables.
ixLogZero = ssGrowth==0 & repmat(ixLog, 1, 1, nAlt);
ssGrowth(ixLogZero) = 1;

if nargout<3
    return
end

% Dtrends alone.
dtLevel = zeros(1, nQty, nAlt);
dtGrowth = zeros(1, nQty, nAlt);
[dtLevel(:, ixy, :), dtGrowth(:, ixy, :)] = getSteadyDtrends(this);

dtLevel(1, ixLog, :) = real(exp(dtLevel(1, ixLog, :)));
dtGrowth(1, ixLog, :) = exp(dtGrowth(1, ixLog, :));

% Steady state plus dtrends.
ssDtLevel = ssLevel;
ssDtLevel(1, ~ixLog, :) = ssDtLevel(1, ~ixLog, :) + dtLevel(1, ~ixLog, :);
ssDtLevel(1, ixLog, :) = ssDtLevel(1, ixLog, :) .* dtLevel(1, ixLog, :);

ssDtGrowth = ssGrowth;
ssDtGrowth(1, ~ixLog, :) = ssDtGrowth(1, ~ixLog, :) + dtGrowth(1, ~ixLog, :);
ssDtGrowth(1, ixLog, :) = ssDtGrowth(1, ixLog, :) .* dtGrowth(1, ixLog, :);
end




function [Dl, Dg] = getSteadyDtrends(this)
TYPE = @int8;
x = model.Variant.getQuantity(this.Variant, ':', ':');
x = permute(x, [2, 1, 3]);
lx = real(x);
gx = imag(x);

nAlt = length(this);
ixy = this.Quantity.Type==TYPE(1); 
ny = sum(ixy);
posy = find(ixy);
ixd = this.Equation.Type==TYPE(3);
eqn = this.Equation;
qty = this.Quantity;

% Return matrix of deterministic trends, Dl, and gradient of dtrends wrt
% exogenous variables, Dg.
Dl = zeros(ny, 1, nAlt);
Dg = zeros(ny, 1, nAlt);
for iEqn = find(ixd)
    % This equation gives dtrend for measurement variable ptr.
    ptr = this.Pairing.Dtrend(iEqn);
    gr = this.Gradient.Dynamic{1, iEqn};
    wrt = this.Gradient.Dynamic{2, iEqn};
    % Add up gradientw wrt individual exogenous variables.
    fn = eqn.Dynamic{iEqn};
    Dl(posy==ptr, 1, :) = fn(lx, 1);
    if ~isempty(wrt) && any(qty.Type(wrt)==TYPE(5))
        for j = 1 : length(wrt)
            if qty.Type(wrt(j))~=TYPE(5)
                continue
            end
            Dg(posy==ptr, 1, :) = ...
                Dg(posy==ptr, 1, :) + ...
                gr{j}(lx, 1) * gx(wrt(j), 1, :);
        end
    end
end
Dl = permute(Dl, [2, 1, 3]);
Dg = permute(Dg, [2, 1, 3]);
end
