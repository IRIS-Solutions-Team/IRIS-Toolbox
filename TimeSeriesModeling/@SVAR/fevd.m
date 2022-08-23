function [X, Y, XX, YY] = fevd(this, time, varargin)
% fevd  Forecast error variance decomposition for SVAR variables.
%
% __Syntax__
%
%     [X, Y, XX, YY] = fevd(V, NPer)
%     [X, Y, XX, YY] = fevd(V, Range)
%
%
% __Input arguments__
%
% * `V` [ VAR ] - Structural VAR model.
%
% * `NPer` [ numeric ] - Number of periods.
%
% * `Range` [ numeric ] - Date range.
%
%
% __Output arguments__
%
% * `X` [ namedmat | numeric ] - Forecast error variance decomposition into
% absolute contributions of residuals; absolute contributions sum up to the
% total variance.
%
% * `Y` [ namedmat | numeric ] - Forecast error variance decomposition into
% relative contributions of residuals; relative contributions sum up to
% `1`.
%
% * `XX` [ Series | tseries ] - Database with absolute contributions in
% multicolumn time series for each VAR variable.
%
% * `YY` [ Series | tseries ] - Database with relative contributions in
% multicolumn time series for each VAR variable.
%
%
% __Options__
%
% * `'MatrixFormat='` [ *`'namedmat'`* | `'plain'` ] - Return matrices `X`
% and `Y` as be either [`namedmat`](namedmat/Contents) objects (i.e.
% matrices with named rows and columns) or plain numeric arrays.
%
%
% __Description__
%
% The output matrices `X` and `Y` are Ny-by-Ny-by-Nt-by-NAlt namedmat objects (matrices with named
% rows and columns), where Ny is the number of endogenous variables (and
% hence also structural residuals), Nt is the number of periods, and NAlt
% is the number of alternative parameterizations.
%
% The output databases `XX` and `YY` contain Nt-by-Ny-by-NAlt time series
% (one for each endogenous variable).
%
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.


defaults = { 
    'MatrixFormat', 'namedmat', @validate.matrixFormat
}; 

opt = passvalopt(defaults, varargin{:});


% Tell whether time is `NPer` or `Range`.
[range, numPeriods] = BaseVAR.mytelltime(time);

isNamedMat = strcmpi(opt.MatrixFormat, 'namedmat');

%--------------------------------------------------------------------------

X = [ ];
Y = [ ];
XX = struct( );
YY = struct( );

if isempty(this)
    return
end

ny = size(this.A, 1);
nv = countVariants(this);

Phi = timedom.var2vma(this.A, this.B, numPeriods);
X = cumsum(Phi.^2, 3);
if nargout > 1
    Y = nan(size(X));
end
varVec = this.Std .^ 2;
for v = 1 : nv
    for t = 1 : numPeriods
        if varVec(v) ~= 1
            X(:, :, t, v) = X(:, :, t, v) .* varVec(v);
        end
        Xsum = sum(X(:, :, t, v), 2);
        Xsum = Xsum(:, ones(1, ny));
        if nargout > 1
            Y(:, :, t, v) = X(:, :, t, v) ./ Xsum; %#ok<AGROW>
        end
    end
end

% Create databases `XX` and `YY` from `X` and `Y`.
if nargout > 2 && ~isempty(this.EndogenousNames)
    for i = 1 : ny
        name = this.EndogenousNames(i);
        c = utils.concomment(char(name), this.ResidualNames);
        if nv>1
            c = repmat(c, 1, 1, nv);
        end
        XX.(name) = Series(range, permute(X(i, :, :, :), [3, 2, 4, 1]), c);
        if nargout > 3
            YY.(name) = Series(range, permute(Y(i, :, :, :), [3, 2, 4, 1]), c);
        end
    end
end

% Convert output matrices to namedmat objects if requested
if isNamedMat
    X = namedmat(X, this.EndogenousNames, this.ResidualNames);
    if nargout>1
        Y = namedmat(Y, this.EndogenousNames, this.ResidualNames);
    end
end

end%

