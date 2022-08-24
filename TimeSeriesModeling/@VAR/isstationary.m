function flag = isstationary(this, varargin)
% isstationary  True if all eigenvalues are within unit circle
%
% __Syntax__
%
%     flag = isstationary(V)
%
%
% __Input Arguments__
%
% * `V` [ VAR ] - VAR object whose eigenvalues will be tested for
% stationarity.
%
%
% __Output Arguments__
%
% * `flag` [ `true` | `false` ] - True if all eigenvalues are within unit
% circle.
%
%
% __Options__
%
% * `Tolerance=@auto` [ numeric | `@auto` ] - Tolerance for the
% eigenvalue test.
%

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

persistent pp
if isempty(pp)
    pp = extend.InputParser('VAR.isstationary');
    addRequired(pp, 'VAR', @(x) isa(x, 'VAR'));
    addParameter(pp, 'Tolerance', @auto, @(x) isequal(x, @auto) || validate.numericScalar(x, [0, Inf]));
end
parse(pp, this, varargin{:});
opt = pp.Options;

if isequal(opt.Tolerance, @auto)
    opt.Tolerance = this.Tolerance.Eigen;
end

%--------------------------------------------------------------------------

flag = all( abs(this.EigVal)<=(1-opt.Tolerance), 2 );
flag = reshape(flag, 1, [ ]);

end%

