function [This,Outp] = filter(This,Inp,Range,varargin)
% filter  Filter data using a VAR model.
%
% Syntax
% =======
%
%     [V,Outp] = filter(V,Inp,Range,...)
%
% Input arguments
% ================
%
% * `V` [ VAR ] - Input VAR object.
%
% * `Inp` [ struct ] - Input database from which initial condition will be
% read.
%
% * `Range` [ numeric ] - Forecast range.
%
% Output arguments
% =================
%
% * `V` [ VAR ] - Output VAR object.
%
% * `Outp` [ struct ] - Output database with prediction and/or smoothed
% data.
%
% Options
% ========
%
% * `'cross='` [ numeric | *`1`* ] - Multiply the off-diagonal elements of
% the covariance matrix (cross-covariances) by this factor; `'cross='` must
% be equal to or smaller than `1`.
%
% * `Deviation=false` [ `true` | `false` ] - Both input and output data are
% deviations from the unconditional mean.
%
% * `'meanOnly='` [ `true` | *`false`* ] - Return a plain database with mean
% forecasts only.
%
% * `'omega='` [ numeric | *empty* ] - Modify the covariance matrix of
% residuals for this run of the filter.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2019 IRIS Solutions Team.

% Parse input arguments.
pp = inputParser( );
pp.addRequired('Inp',@(x) isstruct(x));
pp.addRequired('Range',@isnumeric);
pp.parse(Inp,Range);

% Parse options.
opt = passvalopt('VAR.filter',varargin{1:end});

if isequal(Range,Inf)
    utils.error('VAR', ...
        'Cannot use Inf for range in VAR/filter( ).');
end

isSmooth = ~isempty(strfind(opt.output,'smooth'));
isPred = ~isempty(strfind(opt.output,'pred'));

% TODO: Filter.
isFilter = false; % ~isempty(strfind(opt.output,'filter'));

%--------------------------------------------------------------------------

ny = size(This.A,1);
p = size(This.A,2) / max(ny,1);
nAlt = size(This.A,3);
nx = length(This.NamesExogenous);
isX = nx > 0;
isConst = ~opt.Deviation;

Range = Range(1) : Range(end);
xRange = Range(1)-p : Range(end);

if length(Range)<2
    utils.error('iris:VAR:filter','Invalid range specification.') ;
end

% Include pre-sample.
req = datarequest('y*,x*',This,Inp,xRange);
xRange = req.Range;
y = req.Y;
x = req.X;

nPer = length(Range);
yInit = y(:,1:p,:);
y = y(:,p+1:end,:);
x = x(:,p+1:end,:);

nDataY = size(yInit,3);
nDataX = size(x,3);
nOmg = size(opt.omega,3);

nLoop = max([nAlt,nDataY,nDataX,nOmg]);
doChkOptions( );

% Stack initial conditions.
yInit = yInit(:,p:-1:1,:);
yInit = reshape(yInit(:),ny*p,nLoop);

YY = [ ];
doRequestOutp( );

s = struct( );
s.invFunc = @inv;
s.allObs = NaN;
s.tol = 0;
s.reuse = 0;
s.ahead = opt.ahead;

Z = eye(ny);
for iLoop = 1 : nLoop
    
    [iA,iB,iK,iJ,iOmg] = mysystem(This,iLoop);
    
    % User-supplied covariance matrix.
    if ~isempty(opt.omega)
        iOmg(:,:) = opt.omega(:,:,min(iLoop,end));
    end
    
    % Reduce or zero off-diagonal elements in the cov matrix of residuals
    % if requested. This only matters in VARs, not SVARs.
    if double(opt.cross) < 1
        inx = logical(eye(size(iOmg)));
        iOmg(~inx) = double(opt.cross)*iOmg(~inx);
    end

    % Use the `allobserved` option in `varsmoother` only if the cov matrix is
    % full rank. Otherwise, there is singularity.
    s.allObs = rank(iOmg) == ny;
    
    iY = y(:,:,min(iLoop,end));
    iX = x(:,:,min(iLoop,end));
    iYInit = yInit(:,:,min(iLoop,end));
    
    % Collect all deterministic terms (constant and exogenous inputs).
    iKJ = zeros(ny,nPer);
    if isConst
        iKJ = iKJ + iK(:,ones(1,nPer));
    end    
    if isX
        iKJ = iKJ + iJ*iX;
    end
    
    % Run Kalman filter and smoother.
    [~,~,iE2,~,iY2,iPy2,~,iY0,iPy0,iY1,iPy1] = timedom.varsmoother( ...
        iA,iB,iKJ,Z,[ ],iOmg,[ ],iY,[ ],iYInit,0,s);
    
    % Add pre-sample periods and assign hdata.
    doAssignOutp( );
    
end

% Final output database.
Outp = hdataobj.hdatafinal(YY);


% Nested fuctions...


%**************************************************************************

    
    function doChkOptions( )
        if nLoop > 1 && opt.ahead > 1
            utils.error('VAR', ...
                ['Cannot run filter( ) with option ``ahead=`` greater than 1 ', ...
                'on multiple parameterisations or multiple data sets.']);
        end
        if ~isPred
            opt.ahead = 1;
        end
    end % doChkOptions( )


%**************************************************************************

    
    function doRequestOutp( )
        if isSmooth
            YY.M2 = hdataobj(This,xRange,nLoop);
            if ~opt.meanonly
                YY.S2 = hdataobj(This,xRange,nLoop, ...
                    'IsVar2Std=',true);
            end
        end
        if isPred
            nPred = max(nLoop,opt.ahead);
            YY.M0 = hdataobj(This,xRange,nPred);
            if ~opt.meanonly
                YY.S0 = hdataobj(This,xRange,nPred, ...
                    'IsVar2Std=',true);
            end
        end
        if isFilter
            YY.M1 = hdataobj(This,xRange,nLoop);
            if ~opt.meanonly
                YY.S1 = hdataobj(This,xRange,nLoop, ...
                    'IsVar2Std=',true);
            end
        end
    end % doRequestOutp( )


%**************************************************************************


    function doAssignOutp( )
        if isSmooth
            iY2 = [nan(ny,p),iY2];
            iY2(:,p:-1:1) = reshape(iYInit,ny,p);
            iX2 = [nan(nx,p),iX];
            iE2 = [nan(ny,p),iE2];
            hdataassign(YY.M2,iLoop, { iY2,iX2,iE2,[ ] } );
            if ~opt.meanonly
                iD2 = covfun.cov2var(iPy2);
                iD2 = [zeros(ny,p),iD2];
                hdataassign(YY.S2,iLoop, { iD2,[ ],[ ],[ ] } );
            end
        end
        if isPred
            iY0 = [nan(ny,p,s.ahead),iYInit];
            iE0 = [nan(ny,p,s.ahead),zeros(ny,nPer,s.ahead)];
            if s.ahead > 1
                pos = 1 : s.ahead;
            else
                pos = iLoop;
            end
            hdataassign(YY.M0,pos, { iY0,[ ],iE0,[ ] } );
            if ~opt.meanonly
                iD0 = covfun.cov2var(iPy0);
                iD0 = [zeros(ny,p),iD0];
                hdataassign(YY.S0,iLoop, { iD0,[ ],[ ],[ ] } );
            end
        end
        if isFilter
            iY1 = [nan(ny,p),iY1];
            iX1 = [nan(nx,p),iX];
            iE1 = [nan(ny,p),zeros(ny,nPer)];
            hdataassign(YY.M1,pos, { iY1,iX1,iE1,[ ] } );
            if ~opt.meanonly
                iD1 = covfun.cov2var(iPy1);
                iD1 = [zeros(ny,p),iD1];
                hdataassign(YY.S1,iLoop, { iD1,[ ],[ ],[ ] } );
            end
        end
    end % doAssignOutp( )


end
