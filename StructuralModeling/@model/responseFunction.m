function [s, range, listOfShocks] = responseFunction(this, time, func, listOfShocks, opt)
% responseFunction  Response function. 
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

TIME_SERIES_CONSTRUCTOR = getappdata(0, 'TIME_SERIES_CONSTRUCTOR');
TEMPLATE_SERIES = TIME_SERIES_CONSTRUCTOR( );
TYPE = @int8;

% Parse required input arguments.
pp = inputParser( );
pp.addRequired('M', @(x) isa(this, 'model'));
pp.addRequired('Time', @DateWrapper.validateDateInput);
pp.parse(this, time);

% Tell whether time is nper or range.
if ischar(time)
    time = textinp2dat(time);
elseif length(time) == 1 && round(time) == time && time > 0
    time = 1 : time;
end
range = time(1) : time(end);
numOfPeriods = length(range);

%--------------------------------------------------------------------------

ixy = this.Quantity.Type==TYPE(1);
ixx = this.Quantity.Type==TYPE(2);
ixe = this.Quantity.Type==TYPE(31) | this.Quantity.Type==TYPE(32);
ixg = this.Quantity.Type==TYPE(5);
nx = sum(ixx);
[ny, nxx] = sizeOfSolution(this.Vector);
posx = find(ixx);
nv = length(this);
numOfRuns = length(listOfShocks);
idReal = real([this.Vector.Solution{2}]);
idImag = imag([this.Vector.Solution{2}]);
maxLag = -min(idImag);


% Simulate response function
%----------------------------
% Output data from `timedom.srf` and `timedom.icrf` include the pre-sample
% period.
Phi = nan(ny+nxx, numOfRuns, numOfPeriods+1, nv);

ixSolved = true(1, nv);
for iAlt = 1 : nv
    [T, R, K, Z, H, D, U] = sspaceMatrices(this, iAlt, false); %#ok<ASGLU>
    
    % Continue immediately if solution is not available.
    ixSolved(iAlt) = all(~isnan(T(:)));
    if ~ixSolved(iAlt)
        continue
    end
    
    Phi(:, :, :, iAlt) = func(T, R, [ ], Z, H, [ ], U, [ ], iAlt, numOfPeriods);
end

% Report NaN solutions.
if ~all(ixSolved)
    throw( ...
        exception.Base('Model:SolutionNotAvailable', 'warning'), ...
        exception.Base.alt2str(~ixSolved) ...
    );
end

% Create output data
%--------------------
s = struct( );

% Permute Phi so that Phi(k, t, m, n) is the response of the k-th variable to
% m-th init condition at time t in parameterisation n.
Phi = permute(Phi, [1, 3, 2, 4]);

% Measurement variables.
Y = Phi(1:ny, :, :, :);
for i = find(ixy)
    y = permute(Y(i, :, :, :), [2, 3, 4, 1]);
    isLog = this.Quantity.IxLog(i);
    if opt.delog && isLog
        y = real(exp(y));
    end
    name = this.Quantity.Name{i};
    c = utils.concomment(name, listOfShocks, isLog);
    c = repmat(c, [1, 1, nv]);
    s.(name) = replace(TEMPLATE_SERIES, y, range(1)-1, c);
end

% Transition variables.
X = reshapeXX2X(Phi(ny+1:end, :, :, :));
for i = 1 : nx
    ithPosition = posx(i);
    x = permute(X(i, :, :, :), [2, 3, 4, 1]);
    isLog = this.Quantity.IxLog(ithPosition);
    if opt.delog && isLog
        x = real(exp(x));
    end
    name = this.Quantity.Name{ithPosition};
    c = utils.concomment(name, listOfShocks, isLog);
    c = repmat(c, [1, 1, nv]);
    s.(name) = replace(TEMPLATE_SERIES, x, range(1)-1-maxLag, c);
end

% Shocks.
e = zeros(numOfPeriods, numOfRuns, nv);
for i = find(ixe)
    name = this.Quantity.Name{i};
    c = utils.concomment(name, listOfShocks, false);
    % @@@@@ MOSW.
    c = repmat(c, [1, 1, nv]);
    s.(name) = replace(TEMPLATE_SERIES, e, range(1), c);
end

% Parameters.
s = addparam(this, s);

% Exogenous variables.
g = zeros(numOfPeriods, numOfRuns, nv);
for i = find(ixg)
    name = this.Quantity.Name{i};
    c = utils.concomment(name, listOfShocks, false);
    c = repmat(c, [1, 1, nv]);
    s.(name) = replace(TEMPLATE_SERIES, g, range(1), c);
end

return


    function X = reshapeXX2X(XX)
        sizeOfXX = size(XX);
        XX = XX(:, :, :);
        X = nan(nx, size(XX, 2)+maxLag, size(XX, 3));
        for ii = find(idImag==0)
            outpRow = idReal(ii)==posx;
            X(outpRow, maxLag+1:end, :) = XX(ii, :, :);
            ix = idReal==idReal(ii);
            if any( idImag(ix)<0 )
                for j = 1 : maxLag
                    p = idReal==idReal(ii) & idImag==-j;
                    if any(p)
                        X(outpRow, maxLag+1-j, :) = XX(p, 1, :);
                    end
                end
            end
        end
        if length(sizeOfXX)>3
            X = reshape(X, [size(X, 1), size(X, 2), sizeOfXX(3:end)]);
        end
    end
end
