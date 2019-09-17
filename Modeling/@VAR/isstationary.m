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
% * `Tolerance=@default` [ numeric | `@default` ] - Tolerance for the
% eigenvalue test.
%

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

persistent parser
if isempty(parser)
    parser = extend.InputParser('VAR.isstationary');
    parser.addRequired(  'VAR', @(x) isa(x, 'VAR'));
    parser.addParameter( 'Tolerance', @default, @(x) isequal(x, @default) || validate.numericScalar(x, [0, Inf]));
end
parse(parser, this, varargin{:});
opt = parser.Options;

if isequal(opt.Tolerance, @default)
    opt.Tolerance = this.TOLERANCE;
end

%--------------------------------------------------------------------------

flag = all(abs(this.EigVal) <= 1-opt.Tolerance, 2);
flag = transpose(flag(:));

end%

