function this = defineSystemFunc(this, m)
% defineSystemFunc  Define all valid system prior functions.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

%--------------------------------------------------------------------------

yVec = implementGet(m, 'yVector');
xVec = implementGet(m, 'xVector');
eVec = implementGet(m, 'eVector');
yVec = yVec(:).';
xVec = xVec(:).';
eVec = eVec(:).';

s = struct( );

% Shock response function.
s.srf.rowName = [yVec, xVec];
s.srf.colName = eVec;
s.srf.defaultPageStr = '1';
s.srf.validatePage = @(x) isnumeric(x) && all(x >= 1) && all(isround(x));
s.srf.page = zeros(1, 0);
s.srf.activeInput = false(1, length(s.srf.colName));

% Filter frequency response function.
s.ffrf.rowName = xVec;
s.ffrf.colName = yVec;
s.ffrf.defaultPageStr = 'NaN';
s.ffrf.validatePage = @isnumeric;
s.ffrf.page = zeros(1, 0);
s.ffrf.activeInput = false(1, length(s.ffrf.colName));

% Covariance.
s.cov.rowName = [yVec, xVec];
s.cov.colName = [yVec, xVec];
s.cov.defaultPageStr = '0';
s.cov.validatePage = @(x) isnumeric(x) && all(x >= 0) && all(isround(x));
s.cov.page = zeros(1, 0);
s.cov.activeInput = false(1, length(s.cov.colName));

% Correlation.
s.corr.rowName = [yVec, xVec];
s.corr.colName = [yVec, xVec];
s.corr.defaultPageStr = '0';
s.corr.validatePage = @(x) isnumeric(x) && all(x >= 0) && all(isround(x));
s.corr.page = zeros(1, 0);
s.corr.activeInput = false(1, length(s.corr.colName));

% Power spectrum.
s.pws.rowName = [yVec, xVec];
s.pws.colName = [yVec, xVec];
s.pws.defaultPageStr = 'NaN';
s.pws.validatePage = @isnumeric;
s.pws.page = zeros(1, 0);
s.pws.activeInput = false(1, length(s.pws.colName));

% Spectral density.
s.spd.rowName = [yVec, xVec];
s.spd.colName = [yVec, xVec];
s.spd.defaultPageStr = 'NaN';
s.spd.validatePage = @isnumeric;
s.spd.page = zeros(1, 0);
s.spd.activeInput = false(1, length(s.spd.colName));

this.SystemFn = s;

end
