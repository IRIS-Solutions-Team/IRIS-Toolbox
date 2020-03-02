function [answ, flag, query] = implementGet(this, query, varargin)
% implementGet  Implement get method for model objects
%
% Backend [IrisToolbox] method
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

EIGEN_TOLERANCE = this.Tolerance.Eigen;
TYPE = @int8;

%--------------------------------------------------------------------------

[answ, flag] = implementGet@shared.UserDataContainer(this, query, varargin{:});
if flag
    return
end

[answ, flag] = implementGet@shared.LoadObjectAsStructWrapper(this, query, varargin{:});
if flag
    return
end

[answ, flag] = implementGet(this.Export, query, varargin{:});
if flag
    return
end

[answ, flag] = implementGet(this.Link, this.Quantity, query, varargin{:});
if flag
    return
end

[answ, flag] = implementGet(this.Quantity, query, varargin{:});
if flag
    return
end

[answ, flag] = implementGet(this.Equation, this.Quantity, this.Pairing, query, varargin{:});
if flag
    return
end

[answ, flag] = implementGet(this.Gradient, query, varargin{:});
if flag
    return
end

[answ, flag] = model.component.Pairing.implementGet(this.Pairing, this.Quantity, query, varargin{:});
if flag
    return
end

[answ, flag] = implementGet(this.Vector, query, varargin{:});
if flag
    return
end

[answ, flag] = implementGet(this.Behavior, query, varargin{:});
if flag
    return
end

answ = [ ];
flag = true;

logStyle = this.Behavior.LogStyleInSolutionVectors;

steadyLevel = [ ];
steadyGrowth = [ ];
dtLevel = [ ];
dtGrowth = [ ];
ssDtLevel = [ ];
ssDtGrowth = [ ];

% Replace alternate names with the default names
if isempty(strfind(query, '.')) && isempty(strfind(query, ':'))
    query = this.myalias(query);
end

% Query relates to steady state.
steadyList = { ...
    'ss', 'steady', 'sslevel', 'level', 'ssgrowth', 'growth', ...
    'steady', 'steadyLevel', 'steadyGrowth', ...
    };
dtrendList = { ...
    'dt', 'dtLevel', 'dtGrowth', ...
    'steady+dt', 'steadyLevel+dtLevel', 'steadyGrowth+dtGrowth', ...
    };
if any(strcmpi(query, dtrendList))
    [steadyLevel, steadyGrowth, dtLevel, dtGrowth, ssDtLevel, ssDtGrowth] = getSteady(this);
elseif any(strcmpi(query, steadyList))
    [steadyLevel, steadyGrowth] = getSteady(this);
end

[~, ~, nb, nf] = sizeOfSolution(this.Vector);
ixe = this.Quantity.Type==TYPE(31) | this.Quantity.Type==TYPE(32);
ne = sum(ixe);
nv = length(this);

cell2DbaseFunc = @(X) cell2struct( ...
    num2cell(permute(X, [2, 3, 1]), 2), ...
    this.Quantity.Name(:), 1);

needsToCheckSolution = false;
needsToAddToDatabank = cell.empty(1, 0);

if strncmpi(query, 'Equations:ParameterValues', length('Equations:ParameterValues'))
    answ = this.Equation.Input';
    format = strtrim(query(length('Equations:ParameterValues')+1:end));
    answ = printParameterValues(this, answ, format);

else

    switch lower(query)
        
        case 'incidence'
            answ = struct( ...
                'Dynamic', implementGet(this.Incidence.Dynamic, 'Incidence'), ...
                'Steady',  implementGet(this.Incidence.Steady, 'Incidence') ...
                );
            
            
        case 'file'
            answ = this.FileName;

            
        case 'param'
            answ = addToDatabank({'Parameters', 'Std', 'NonzeroCorr'}, this);
            
            
        case 'plainparam'
            answ = addToDatabank('Parameters', this);
     

        case 'std'
            answ = addToDatabank('Std', this);
            
            
        case 'corr'
            answ = addToDatabank('Corr', this);


        case 'nonzerocorr'
            answ = addToDatabank('NonzeroCorr', this);
            
            
        case 'stdcorr'
            answ = addToDatabank({'Std', 'Corr'}, this);
            
            
        case 'exogenous'
            ixg = this.Quantity.Type==TYPE(5);
            answ = struct( );
            for i = find(ixg)
                name = this.Quantity.Name{i};
                values = this.Variant.Values(:, i, :);
                answ.(name) = permute(value, [2, 3, 1]);
            end        
            
            
            
            
        case 'stdlist'
            answ = getStdNames(this.Quantity);
            
            
            
            
        case 'corrlist'
            answ = getCorrNames(this.Quantity);
            
            
            
            
        case 'stdcorrlist'
            listOfStdNames = implementGet(this, 'StdList');
            listOfCorrNames = implementGet(this, 'CorrList');
            answ = [listOfStdNames, listOfCorrNames];
            
            
            
            
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
            answ = getIthOmega(this, ':');
            
            
        case {'stdvec'}
            answ = permute(this.Variant.StdCorr(:, 1:ne, :), [2, 3, 1]);
            
            
        case {'stdcorrvec'}
            answ = permute(this.Variant.StdCorr, [2, 3, 1]);
            
            
        case {'nalt', 'numofvariants'}
            answ = nv;
            
            
        case {'nametype'}
            answ = this.Quantity.Type;
            
            
        case 'build'
            answ = this.Build;

            
        case {'preparser', 'preparsercontrol', 'pset', 'controlparameters'}
            answ = this.PreparserControl;


        case {'substitutions'}
            answ = this.Substitutions;

            
        case 'steady'
            answ = cell2DbaseFunc(steadyLevel+1i*steadyGrowth);
            needsToAddToDatabank = {'Std', 'NonzeroCorr'};
            
            
        case 'steadylevel'
            answ = cell2DbaseFunc(steadyLevel);
            needsToAddToDatabank = {'Std', 'NonzeroCorr'};
            
            
        case 'steadygrowth'
            answ = cell2DbaseFunc(steadyGrowth);
            needsToAddToDatabank = {'Std', 'NonzeroCorr'};


        case 'dt'
            answ = cell2DbaseFunc(dtLevel+1i*dtGrowth);
            needsToAddToDatabank = {'Std', 'NonzeroCorr'};
            
            
        case 'dtlevel'
            answ = cell2DbaseFunc(dtLevel);
            needsToAddToDatabank = {'Std', 'NonzeroCorr'};

            
        case 'dtgrowth'
            inxNaNSolutions = this.Quantity.Type==TYPE(1);
            answ = cell2DbaseFunc(dtGrowth);
            needsToAddToDatabank = {'Std', 'NonzeroCorr'};
            
        case 'steady+dt'
            answ = cell2DbaseFunc(ssDtLevel+1i*ssDtGrowth);
            needsToAddToDatabank = {'Std', 'NonzeroCorr'};
            
        case 'steadylevel+dtlevel'
            answ = cell2DbaseFunc(ssDtLevel);
            needsToAddToDatabank = {'Std', 'NonzeroCorr'};
            
        case 'steadygrowth+dtgrowth'
            answ = cell2DbaseFunc(ssDtGrowth);
            needsToAddToDatabank = {'Std', 'NonzeroCorr'};
            
        case {'eig', 'eigval', 'roots'}
            answ = eig(this);
            
        case 'rlist'
            answ = implementGet(this.Reporting, 'list');
                    
        case 'reqtn'
            answ = implementGet(this.Reporting, 'eqtn');
            
        case 'rlabel'
            answ = implementGet(this.Reporting, 'label');
            
        case {'yvector', 'yvec'}
            answ = printSolutionVector(this, 'y', logStyle);
            answ = answ.';
            
        case {'xvector', 'xvec'}
            answ = printSolutionVector(this, 'x', logStyle);
            answ = answ.';
            
        case {'xfvector', 'xfvec'}
            answ = printSolutionVector(this, 'x', logStyle);
            answ = answ(1:nf);
            answ = answ.';
            
        case {'xbvector', 'xbvec'}
            answ = printSolutionVector(this, 'x', logStyle);
            answ = answ(nf+1:end);
            answ = answ.';
            
        case {'evector', 'evec'}
            answ = printSolutionVector(this, 'e', logStyle);
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
            needsToCheckSolution = true;
            getStationary(query);

            
        case 'maxlag'
            maxLagDynamic = this.Incidence.Dynamic.MinShift;
            maxLagSteady = this.Incidence.Steady.MinShift;
            answ = min(maxLagDynamic, maxLagSteady);
            
            
        case 'maxlead'
            maxLeadDynamic = this.Incidence.Dynamic.MaxShift;
            maxLeadSteady = this.Incidence.Steady.MaxShift;
            answ = max(maxLeadDynamic, maxLeadSteady);
            
            
            
            
        case {'icond', 'initcond', 'required', 'requiredinitcond'}
            % True initial conditions required at least in one parameter variant.
            vecXb = this.Vector.Solution{2}(nf+1:end);
            ixInit = any(this.Variant.IxInit, 3);
            answ = printSolutionVector(this, vecXb(ixInit)-1i, logStyle);
            
            
            
            
        case {'forward'}
            answ = size(this.Variant.FirstOrderSolution{2}, 2)/ne - 1;
            needsToCheckSolution = true;
            
            
        case {'stableroots', 'unitroots', 'unstableroots'}
            eigenValues = this.Variant.EigenValues;
            eigenStability = this.Variant.EigenStability;
            switch query
                case 'stableroots'
                    ixSelect = eigenStability==TYPE(0);
                case 'unstableroots'
                    ixSelect = eigenStability==TYPE(2);
                case 'unitroots'
                    ixSelect = eigenStability==TYPE(1);
            end
            answ = nan(size(eigenValues));
            for v = 1 : nv
                n = nnz(ixSelect(1, :, v));
                answ(1, 1:n, v) = eigenValues(1, ixSelect(1, :, v), v);
            end
            answ(:, all(isnan(answ), 3), :) = [ ];
            
            
        case 'epsilon'
            answ = this.Tolerance.DiffStep;
            
            
        case 'userdata'
            answ = userdata(this);




        % Database of autoexogenise definitions d.variable = 'shock';
        case {'autoexogenise', 'autoexogenised', 'autoexogenize', 'autoexogenized'}
            answ = autoexogenise(this);
            
            
            
            
        case {'autoswap', 'autoswaps', 'autoexog'}
            answ = autoswap(this);

            
        case {'reporting', 'rpteq'}
            answ = this.Reporting;
            
            
        case 'nx'
            answ = length(this.Vector.Solution{2});
            
            
            
            
        case 'nb'
            answ = size(this.Variant.FirstOrderSolution{7}, 1);
            
            
            
            
        case 'nf'
            answ = length(this.Vector.Solution{2}) - size(this.Variant.FirstOrderSolution{7}, 1);
            
            
            
            
        case 'ny'
            answ = sum(this.Quantity.Type==TYPE(1));
            
            
            
            
        case 'ng'
            answ = sum(this.Quantity.Type==TYPE(5));
            
            
            
            
        case 'ne'
            answ = sum(this.Quantity.Type==TYPE(31) | this.Quantity.Type==TYPE(32));
            



        case {'islinear', 'linear'}
            answ = this.IsLinear;




        case {'isgrowth', 'growth'}
            answ = this.IsGrowth;



            
        case {'lastsyst', 'lastsystem'}
            answ = this.LastSystem;
            



        otherwise
            flag = false;
            
    end

end

if needsToCheckSolution
    % Report solution(s) not available.
    [solutionFlag, inxNaNSolutions] = isnan(this, 'solution');
    if solutionFlag
        utils.warning('model:implementGet', ...
            'Solution(s) not available %s.', ...
            exception.Base.alt2str(inxNaNSolutions) );
    end
end

% Add parameters, std devs and non-zero cross-corrs.
if ~isempty(needsToAddToDatabank)
    answ = addToDatabank(needsToAddToDatabank, this, answ);
end

return




    function getStationary(query)
        if strncmpi(query, 'is', 2)
            query(1:2) = '';
        end
        vecXb = [this.Vector.Solution{1:2}];
        t0 = imag(vecXb)==0;
        name = this.Quantity.Name( real(vecXb(t0)) );
        [~, inxNaNSolutions] = isnan(this, 'solution');
        status = nan([sum(t0), nv]);
        for iiAlt = find(~inxNaNSolutions)
            inxUnitRoots = this.Variant.EigenStability(:, 1:nb, iiAlt)==TYPE(1);
            dy = any(abs(this.Variant.FirstOrderSolution{4}(:, inxUnitRoots, iiAlt))>EIGEN_TOLERANCE, 2).';
            df = any(abs(this.Variant.FirstOrderSolution{1}(1:nf, inxUnitRoots, iiAlt))>EIGEN_TOLERANCE, 2).';
            db = any(abs(this.Variant.FirstOrderSolution{7}(:, inxUnitRoots, iiAlt))>EIGEN_TOLERANCE, 2).';
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
            if nv==1
                answ = name(status==true | status==1);
                answ = answ(:)';
            else
                answ = cell([1, nv]);
                for ii = 1 : nv
                    answ{ii} = name(status(:, ii)==true | status(:, ii)==1);
                    answ{ii} = answ{ii}(:).';
                end
            end
        else
            % Database.
            answ = cell2struct( num2cell(status, 2), name(:), 1 );
        end
    end%
end%


function [ steadyLevel, steadyGrowth, ...
           dtLevel, dtGrowth, ...
           ssDtLevel, ssDtGrowth ] = getSteady(this)
    TYPE = @int8;

    numOfQuantities = length(this.Quantity);
    nv = length(this.Variant);
    ixy = this.Quantity.Type==TYPE(1);
    inxLog = this.Quantity.IxLog;

    % Steady states.
    ss = this.Variant.Values;
    steadyLevel = real(ss);
    steadyGrowth = imag(ss);

    % Fix missing (=zero) growth in steady states of log variables.
    ixLogZero = steadyGrowth==0 & repmat(inxLog, 1, 1, nv);
    steadyGrowth(ixLogZero) = 1;

    if nargout<3
        return
    end

    % Dtrends alone.
    dtLevel = zeros(1, numOfQuantities, nv);
    dtGrowth = zeros(1, numOfQuantities, nv);
    [dtLevel(:, ixy, :), dtGrowth(:, ixy, :)] = getSteadyDtrends(this);

    dtLevel(1, inxLog, :) = real(exp(dtLevel(1, inxLog, :)));
    dtGrowth(1, inxLog, :) = exp(dtGrowth(1, inxLog, :));

    % Steady state plus dtrends.
    ssDtLevel = steadyLevel;
    ssDtLevel(1, ~inxLog, :) = ssDtLevel(1, ~inxLog, :) + dtLevel(1, ~inxLog, :);
    ssDtLevel(1, inxLog, :) = ssDtLevel(1, inxLog, :) .* dtLevel(1, inxLog, :);

    ssDtGrowth = steadyGrowth;
    ssDtGrowth(1, ~inxLog, :) = ssDtGrowth(1, ~inxLog, :) + dtGrowth(1, ~inxLog, :);
    ssDtGrowth(1, inxLog, :) = ssDtGrowth(1, inxLog, :) .* dtGrowth(1, inxLog, :);
end%




function [Dl, Dg] = getSteadyDtrends(this)
    TYPE = @int8;
    x = permute(this.Variant.Values, [2, 1, 3]);
    lx = real(x);
    gx = imag(x);

    nv = length(this);
    ixy = this.Quantity.Type==TYPE(1); 
    ny = sum(ixy);
    posy = find(ixy);
    ixd = this.Equation.Type==TYPE(3);
    eqn = this.Equation;
    qty = this.Quantity;

    % Return matrix of deterministic trends, Dl, and gradient of dtrends wrt
    % exogenous variables, Dg.
    Dl = zeros(ny, 1, nv);
    Dg = zeros(ny, 1, nv);
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
end%




function equations = printParameterValues(this, equations, format)
    TYPE = @int8;
    posp = find(this.Quantity.Type==TYPE(4));
    if isempty(format)
        format = '%.2f';
    end
    nump = length(posp);
    names = cell(1, nump);
    values = cell(1, nump);
    for i = posp
        names{i} = ['\<', this.Quantity.Name{i}, '\>'];
        values{i} = sprintf(format, this.Variant.Values(1, i, 1));
    end
    equations = regexprep(equations, names, values);
end%


%{
function steadyTable = getSteadyTable(this, values)
    names = this.Quantity.Name(
%}

