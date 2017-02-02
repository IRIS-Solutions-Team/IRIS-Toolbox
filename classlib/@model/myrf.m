function [s, range, lsShock] = myrf(this, time, func, lsShock, opt)
% myrf  [Not a public function] Response function backend.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

TEMPLATE_SERIES = Series( );

% Parse required input arguments.
pp = inputParser( );
pp.addRequired('M',@(x) isa(this,'model'));
pp.addRequired('Time',@(x) isdatinp(x));
pp.parse(this,time);

% Tell whether time is nper or range.
if ischar(time)
    time = textinp2dat(time);
elseif length(time) == 1 && round(time) == time && time > 0
    time = 1 : time;
end
range = time(1) : time(end);
nPer = length(range);

%--------------------------------------------------------------------------

ixy = this.Quantity.Type==int8(1);
ixx = this.Quantity.Type==int8(2);
ixe = this.Quantity.Type==int8(31) | this.Quantity.Type==int8(32);
ixg = this.Quantity.Type==int8(5);
nx = sum(ixx);
[ny, nxx] = sizeOfSolution(this.Vector);
posx = find(ixx);
nAlt = length(this);
nRun = length(lsShock);
idReal = real([this.Vector.Solution{2}]);
idImag = imag([this.Vector.Solution{2}]);
maxLag = -min(idImag);


% Simulate response function
%----------------------------
% Output data from `timedom.srf` and `timedom.icrf` include the pre-sample
% period.
Phi = nan(ny+nxx, nRun, nPer+1, nAlt);

ixSolved = true(1, nAlt);
for iAlt = 1 : nAlt
    [T,R,K,Z,H,D,U] = mysspace(this,iAlt,false); %#ok<ASGLU>
    
    % Continue immediately if solution is not available.
    ixSolved(iAlt) = all(~isnan(T(:)));
    if ~ixSolved(iAlt)
        continue
    end
    
    Phi(:,:,:,iAlt) = func(T,R,[ ],Z,H,[ ],U,[ ],iAlt, nPer);
end

% Report NaN solutions.
if ~all(ixSolved)
    utils.warning('model:myrf', ...
        'Solution(s) not available %s.', ...
        exception.Base.alt2str(~ixSolved) );
end

% Create output data
%--------------------
s = struct( );

% Permute Phi so that Phi(k,t,m, n) is the response of the k-th variable to
% m-th init condition at time t in parameterisation n.
Phi = permute(Phi,[1,3,2,4]);

% Measurement variables.
Y = Phi(1:ny,:,:,:);
for i = find(ixy)
    y = permute(Y(i,:,:,:), [2,3,4,1]);
    isLog = this.Quantity.IxLog(i);
    if opt.delog && isLog
        y = real(exp(y));
    end
    name = this.Quantity.Name{i};
    c = utils.concomment(name, lsShock, isLog);
    % @@@@@ MOSW.
    % Matlab accepts repmat(c,1,1, nAlt), too.
    c = repmat(c, [1, 1, nAlt]);
    s.(name) = replace(TEMPLATE_SERIES,y,range(1)-1,c);
end

% Transition variables.
X = reshapeXX2X(Phi(ny+1:end,:,:,:));
for i = 1 : nx
    pos = posx(i);
    x = permute(X(i,:,:,:), [2,3,4,1]);
    isLog = this.Quantity.IxLog(pos);
    if opt.delog && isLog
        x = real(exp(x));
    end
    name = this.Quantity.Name{pos};
    c = utils.concomment(name, lsShock, isLog);
    % @@@@@ MOSW.
    c = repmat(c, [1, 1, nAlt]);
    s.(name) = replace(TEMPLATE_SERIES, x, range(1)-1-maxLag, c);
end

% Shocks.
e = zeros(nPer, nRun, nAlt);
for i = find(ixe)
    name = this.Quantity.Name{i};
    c = utils.concomment(name, lsShock, false);
    % @@@@@ MOSW.
    c = repmat(c, [1, 1, nAlt]);
    s.(name) = replace(TEMPLATE_SERIES, e, range(1), c);
end

% Parameters.
s = addparam(this, s);

% Exogenous variables.
g = zeros(nPer, nRun, nAlt);
for i = find(ixg)
    name = this.Quantity.Name{i};
    c = utils.concomment(name, lsShock, false);
    % @@@@@ MOSW.
    % Matlab accepts repmat(c,1,1, nAlt), too.
    c = repmat(c, [1, 1, nAlt]);
    s.(name) = replace(TEMPLATE_SERIES, g, range(1), c);
end

return




    function X = reshapeXX2X(XX)
        sz = size(XX);
        XX = XX(:, :, :);
        X = nan(nx, size(XX, 2)+maxLag, size(XX, 3));
        for ii = find(idImag==0)
            outpRow = idReal(ii)==posx;
            X(outpRow, maxLag+1:end, :) = XX(ii,:,:);
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
        if length(sz)>3
            X = reshape(X, [size(X,1), size(X,2), sz(3:end)]);
        end
    end
end
