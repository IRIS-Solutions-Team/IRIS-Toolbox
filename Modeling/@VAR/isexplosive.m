function flag = isexplosive(this, varargin)
% isexplosive  True if any eigenvalue is outside unit circle
%
% __Syntax__
%
%     flag = isexplosive(v)
%
%
% __Input Arguments__
%
% * `v` [ VAR ] - VAR object whose eigenvalues will be tested for
% instability.
%
%
% __Output Arguments__
%
% * `flag` [ `true` | `false` ] - True if at least one eigenvalue is
% outside unit circle.
%
%
% __Options__
%
% * `Tolerance=@default` [ numeric | `@default` ] - Tolerance for the
% eigenvalue test; `@default` means `eps( )^(5/9)`.
%
%
% __Description__
%
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

persistent parser
if isempty(parser)
    parser = extend.InputParser('VAR.isexplosive');
    parser.addRequired(  'VAR', @(x) isa(x, 'VAR'));
    parser.addParameter( 'Tolerance', @default, @(x) isequal(x, @default) || validate.numericScalar(x, [0, Inf]));
end
try
parse(parser, this, varargin{:});
catch, keyboard, end
opt = parser.Options;

if isequal(opt.Tolerance, @default)
    opt.Tolerance = this.TOLERANCE;
end

%--------------------------------------------------------------------------

flag = any(abs(this.EigVal) > 1+opt.Tolerance, 2);
flag = transpose(flag(:));

end%

