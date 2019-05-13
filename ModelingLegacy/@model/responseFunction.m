function [s, range, namesOfResponses] = responseFunction(this, time, func, namesOfResponses, opt)
% responseFunction  Response function 
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

TIME_SERIES_CONSTRUCTOR = iris.get('DefaultTimeSeriesConstructor');
TIME_SERIES_TEMPLATE = TIME_SERIES_CONSTRUCTOR( );
TYPE = @int8;

% Parse required input arguments.
pp = inputParser( );
pp.addRequired('M', @(x) isa(this, 'model'));
pp.addRequired('Time', @DateWrapper.validateDateInput);
pp.parse(this, time);

% Tell whether time is nper or range.
if ischar(time)
    time = textinp2dat(time);
elseif length(time)==1 && round(time)==time && time>0
    time = 1 : time;
end
range = time(1) : time(end);
numPeriods = length(range);

%--------------------------------------------------------------------------

ixy = this.Quantity.Type==TYPE(1);
ixx = this.Quantity.Type==TYPE(2);
ixe = this.Quantity.Type==TYPE(31) | this.Quantity.Type==TYPE(32);
ixg = this.Quantity.Type==TYPE(5);
nx = sum(ixx);
[ny, nxx] = sizeOfSolution(this.Vector);
posx = find(ixx);
nv = length(this);
numRuns = length(namesOfResponses);
idReal = real([this.Vector.Solution{2}]);
idImag = imag([this.Vector.Solution{2}]);
maxLag = -min(idImag);


% __Simulate Response Function__
% Output data from `timedom.srf` and `timedom.icrf` include the pre-sample
% period.
Phi = nan(ny+nxx, numRuns, numPeriods+1, nv);
indexOfSolutionsAvailable = issolved(this);
for v = find(indexOfSolutionsAvailable)
    [T, R, K, Z, H, D, U] = sspaceMatrices(this, v, false); %#ok<ASGLU>
    Phi(:, :, :, v) = func(T, R, [ ], Z, H, [ ], U, [ ], v, numPeriods);
end
% Report NaN solutions.
if any(~indexOfSolutionsAvailable)
    throw( ...
        exception.Base('Model:SolutionNotAvailable', 'warning'), ...
        exception.Base.alt2str(~indexOfSolutionsAvailable) ...
    );
end

% __Create Output Data__
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
    c = utils.concomment(name, namesOfResponses, isLog);
    c = repmat(c, [1, 1, nv]);
    s.(name) = replace(TIME_SERIES_TEMPLATE, y, range(1)-1, c);
end

% Transition variables.
X = convertXi2X(Phi(ny+1:end, :, :, :));
for i = 1 : nx
    ithPosition = posx(i);
    x = permute(X(i, :, :, :), [2, 3, 4, 1]);
    isLog = this.Quantity.IxLog(ithPosition);
    if opt.delog && isLog
        x = real(exp(x));
    end
    name = this.Quantity.Name{ithPosition};
    c = utils.concomment(name, namesOfResponses, isLog);
    c = repmat(c, [1, 1, nv]);
    s.(name) = replace(TIME_SERIES_TEMPLATE, x, range(1)-1-maxLag, c);
end

% Shocks.
e = zeros(numPeriods, numRuns, nv);
for i = find(ixe)
    name = this.Quantity.Name{i};
    c = utils.concomment(name, namesOfResponses, false);
    % @@@@@ MOSW.
    c = repmat(c, [1, 1, nv]);
    s.(name) = replace(TIME_SERIES_TEMPLATE, e, range(1), c);
end

% Parameters.
s = addToDatabank({'Parameters', 'Std', 'NonzeroCorr'}, this, s);

% Exogenous variables.
g = zeros(numPeriods, numRuns, nv);
for i = find(ixg)
    name = this.Quantity.Name{i};
    c = utils.concomment(name, namesOfResponses, false);
    c = repmat(c, [1, 1, nv]);
    s.(name) = replace(TIME_SERIES_TEMPLATE, g, range(1), c);
end

return


    function X = convertXi2X(XX)
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
