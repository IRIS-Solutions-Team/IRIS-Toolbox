function this = autoexogenize(this, namesToExogenize, dates, sigma)
% autoexogenize  Exogenize variables and automatically endogenize corresponding shocks.
%
% Syntax
% =======
%
%     P = autoexogenize(P,List,Dates)
%     P = autoexogenize(P,List,Dates,Sigma)
%
%
% Input arguments
% ================
%
% * `P` [ plan ] - Simulation plan.
%
% * `List` [ cellstr | char | `@all` ] - List of variables that will be
% exogenized; these variables must have their corresponding shocks definid
% in the [`!dynamic_autoxeog`](irislang/dynamicautoexog) section of the
% model file; `@all` means all autoexogenized variables defined in the
% model object will be exogenized.
%
% * `Dates` [ numeric ] - Dates at which the variables will be exogenized.
%
% * `Sigma` [ `1` | `1i` | numeric ] - Anticipation mode (real or
% imaginary) for endogenized shocks, and their numerical weight (used
% in underdetermined simulation plans); if omitted, `Sigma = 1`.
%
%
% Output arguments
% =================
%
% * `P` [ plan ] - Simulation plan with new information on exogenized
% variables and endogenized shocks included.
%
%
% Description
% ============
%
%
% Example
% ========
%
% Assume that the underlying model file included the following sections:
%
%     !transition-variables
%         X, Y, Z
%     !transition-shocks
%         a, b, c
%     !dynamic-exog
%         X := a
%         Y := c
%         Z := d
%
% Then running the following commands
%
%     p = plan(m, range);
%     p = autoexogenize(p, 'X, Y', range(1:5));
%
% will exogenize `X` and `Y` while automatically endogenizing shocks `a`
% and `c` in the first five simulation periods.
%
% Using the keyword `@all` in the following command
%
%     p = plan(m, range);
%     p = autoexogenize(p, @all, range(1:5));
%
% will exogenize all three variables defined in the
% [`!dynamic_autoexog`](irislang/dynamicautoexog) section, i.e. `X`, `Y`
% and `Z`, and endogenize all three corresponding shocks `a`, `b`, and `c`.
%


% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%#ok<*VUNUS>
%#ok<*CTCH>

try
    sigma;
catch
    sigma = 1;
end

if isnumeric(namesToExogenize) && (ischar(dates) || iscellstr(dates))
    [namesToExogenize, dates] = deal(dates, namesToExogenize);
end

% Parse required input arguments.
isnumericscalar = @(x) isnumeric(x) && isscalar(x);
pp = inputParser( );
pp.addRequired('List', @(x) ischar(x) || iscellstr(x) || isa(x, 'string') || isequal(x,@all));
pp.addRequired('Dates', @isnumeric);
pp.addRequired('Sigma', ...
    @(x) isnumericscalar(x) && ~(real(x)~=0 && imag(x)~=0) ...
    && real(x)>=0 && imag(x)>=0 && x~=0);
pp.parse(namesToExogenize, dates, sigma);

% Convert char list to cell of str.
if ischar(namesToExogenize)
    namesToExogenize = regexp(namesToExogenize, '[A-Za-z]\w*', 'match');
elseif isa(namesToExogenize, 'string')
    namesToExogenize = cellstr(namesToExogenize);
end

if isempty(namesToExogenize)
    return
end

%--------------------------------------------------------------------------

n = length(this.XList);
nList = numel(namesToExogenize);
indexToExogenize = false(1, n);
indexToEndogenize = false(1, n);
invalidNames = cell.empty(1, 0);

if isequal(namesToExogenize, @all)
    indexToExogenize = ~isnan(this.AutoX);
else
    for i = 1 : nList
        posX = find(strcmp(this.XList, namesToExogenize{i}));
        if isempty(posX)
            invalidNames(1, end+1) = namesToExogenize(i);
            continue
        end
        indexToExogenize(posX) = true;
    end
end

for i = find(indexToExogenize)
    posN = this.AutoX(i);
    if isnan(posN)
        invalidNames(1, end+1) = this.XList(i);
        continue
    end
    indexToEndogenize(posN) = true;
end

if ~isempty(invalidNames)
    invalidNames = unique(invalidNames);
    utils.error('plan:autoexogenize', ...
        'Cannot autoexogenize this name: %s ', ...
        invalidNames{:});
end

if any(indexToExogenize)
    this = exogenize(this, this.XList(indexToExogenize), dates);
    this = endogenize(this, this.NList(indexToEndogenize), dates, sigma);
end

end
