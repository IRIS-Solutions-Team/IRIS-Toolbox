function [X,Y,XX,YY] = fevd(This,Time,varargin)
% fevd  Forecast error variance decomposition for SVAR variables.
%
% __Syntax__
%
%     [X,Y,XX,YY] = fevd(V,NPer)
%     [X,Y,XX,YY] = fevd(V,Range)
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
% -Copyright (c) 2007-2018 IRIS Solutions Team.

TIME_SERIES_CONSTRUCTOR = getappdata(0, 'IRIS_TimeSeriesConstructor');
opt = passvalopt('SVAR.fevd',varargin{:});

% Tell whether time is `NPer` or `Range`.
[range,nPer] = varobj.mytelltime(Time);

isNamedMat = strcmpi(opt.MatrixFormat,'namedmat');

%--------------------------------------------------------------------------

X = [ ];
Y = [ ];
XX = struct( );
YY = struct( );

if isempty(This)
    return
end

ny = size(This.A,1);
nAlt = size(This.A,3);

Phi = timedom.var2vma(This.A,This.B,nPer);
X = cumsum(Phi.^2,3);
if nargout > 1
    Y = nan(size(X));
end
varVec = This.Std .^ 2;
for iAlt = 1 : nAlt
    for t = 1 : nPer
        if varVec(iAlt) ~= 1
            X(:,:,t,iAlt) = X(:,:,t,iAlt) .* varVec(iAlt);
        end
        Xsum = sum(X(:,:,t,iAlt),2);
        Xsum = Xsum(:,ones(1,ny));
        if nargout > 1
            Y(:,:,t,iAlt) = X(:,:,t,iAlt) ./ Xsum; %#ok<AGROW>
        end
    end
end

% Create databases `XX` and `YY` from `X` and `Y`.
if nargout > 2 && ~isempty(This.NamesEndogenous)
    for i = 1 : ny
        name = This.NamesEndogenous{i};
        c = utils.concomment(name,This.NamesErrors);
        if nAlt > 1
            % @@@@@ MOSW.
            % Matlab accepts repmat(c,1,1,nAlt), too.
            c = repmat(c,[1,1,nAlt]);
        end
        XX.(name) = TIME_SERIES_CONSTRUCTOR(range,permute(X(i,:,:,:),[3,2,4,1]),c);
        if nargout > 3
            YY.(name) = TIME_SERIES_CONSTRUCTOR(range,permute(Y(i,:,:,:),[3,2,4,1]),c);
        end
    end
end

if true % ##### MOSW
    % Convert output matrices to namedmat objects if requested.
    if isNamedMat
        X = namedmat(X,This.NamesEndogenous,This.NamesErrors);
        if nargout > 1
            Y = namedmat(Y,This.NamesEndogenous,This.NamesErrors);
        end
    end
else
    % Do nothing.
end

end
