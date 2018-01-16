function this = autoexogenize(this, lsExog, dates, sigma)
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
% in the [`!dynamic_autoxeog`](modellang/dynamicautoexog) section of the
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
%     !transition_variables
%         X, Y, Z
%     !transition_shocks
%         a, b, c
%     !dynamic_exog
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
% [`!dynamic_autoexog`](modellang/dynamicautoexog) section, i.e. `X`, `Y`
% and `Z`, and endogenize all three corresponding shocks `a`, `b`, and `c`.
%


% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

%#ok<*VUNUS>
%#ok<*CTCH>

try
    sigma;
catch
    sigma = 1;
end

if isnumeric(lsExog) && (ischar(dates) || iscellstr(dates))
    [lsExog, dates] = deal(dates, lsExog);
end

% Parse required input arguments.
pp = inputParser( );
pp.addRequired('List', @(x) ischar(x) || iscellstr(x) || isequal(x,@all));
pp.addRequired('Dates', @isnumeric);
pp.addRequired('Sigma', ...
    @(x) isnumericscalar(x) && ~(real(x)~=0 && imag(x)~=0) ...
    && real(x)>=0 && imag(x)>=0 && x~=0);
pp.parse(lsExog, dates, sigma);

% Convert char list to cell of str.
if ischar(lsExog)
    lsExog = regexp(lsExog, '[A-Za-z]\w*', 'match');
end

if isempty(lsExog)
    return
end

%--------------------------------------------------------------------------

n = length(this.XList);
nList = numel(lsExog);
ixValid = true(1, nList);
ixExg = false(1, n);
ixEndg = false(1, n);

if isequal(lsExog, @all)
    ixExg = ~isnan(this.AutoX);
else
    for i = 1 : nList
        xPos = find(strcmp(this.XList, lsExog{i}));
        if isempty(xPos)
            ixValid(i) = false;
            continue
        end
        ixExg(xPos) = true;
    end
end

for i = find(ixExg)
    nPos = this.AutoX(i);
    if isnan(nPos)
        ixValid(i) = false;
        continue
    end
    ixEndg(nPos) = true;
end

if any(~ixValid)
    utils.error('plan:autoexogenize', ...
        'Cannot autoexogenize this name: %s ', ...
        lsExog{~ixValid});
end

if any(ixExg)
    this = exogenize(this, this.XList(ixExg), dates);
    this = endogenize(this, this.NList(ixEndg), dates, sigma);
end

end
