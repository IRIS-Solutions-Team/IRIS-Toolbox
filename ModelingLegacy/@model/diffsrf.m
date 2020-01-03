function [s, this] = diffsrf(this, time, listOfParams, varargin)
% diffsrf  Differentiate shock response functions w.r.t. specified parameters
%
% ## Syntax ##
%
%     outputDatabank = diffsrf(model, numOfPeriods, listOfParams, ...)
%     outputDatabank = diffsrf(model, range, listOfParams, ...)
%
%
% ## Input Arguments ##
%
% * `model` [ model ] - Model object whose response functions will be
% simulated and differentiated.
%
% * `range` [ numeric | char ] - Simulation date range with the first date
% being the shock date.
%
% * `numOfPeriods` [ numeric ] - Number of simulation periods.
%
% * `listOfParams` [ char | cellstr ] - List of parameters w.r.t. which the
% shock response functions will be differentiated.
%
%
% ## Output Arguments ##
%
% * `outputDatabank` [ struct ] - Database with shock reponse derivatives
% returned in multivariate time series.
%
%
% ## Options ##
%
% See [`model/srf`](model/srf) for options available
%
%
% ## Description ##
%
%
% ## Example ##
%

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 IRIS Solutions Team

TYPE = @int8;

% Convert char list to cellstr.
if ischar(listOfParams)
    listOfParams = regexp(listOfParams, '\w+', 'match');
end

%--------------------------------------------------------------------------

nv = length(this);
ixy = this.Quantity.Type==TYPE(1);
ixx = this.Quantity.Type==TYPE(2);
ixe = this.Quantity.Type==TYPE(31) | this.Quantity.Type==TYPE(32);
ixp = this.Quantity.Type==TYPE(4);
ixg = this.Quantity.Type==TYPE(5);

if nv>1
    THIS_ERROR = { 'Model:CannotRunMultipleVariants'
                   'Cannot run diffsrf(~) on model objects with multiple parameter variants' };
    throw( exception.Base(THIS_ERROR, 'error') );
end

ell = lookup(this.Quantity, listOfParams, TYPE(4));
posOfParams = ell.PosName;
indexOfValidNames = ~isnan(posOfParams);
if any(~indexOfValidNames)
    throw( exception.Base('Model:INVALID_NAME', 'error'), ...
           'parameter ', listOfParams{indexOfValidNames} ); %#ok<GTARG>
end

% Find optimal step for two-sided derivatives
p = this.Variant.Values(1, posOfParams);
numOfParams = numel(posOfParams);
h = eps^(1/3) * max([p; ones(size(p))], [ ], 1);

% Assign alternative parameterisations p(i)+h(i) and p(i)-h(i)
thisWithSteps = alter(this, 2*numOfParams);
P = struct( );
twoSteps = nan(1, numOfParams);
for i = 1 : numOfParams
    pp = p(i)*ones(1, numOfParams);
    pp(i) = p(i) + h(i);
    pm = p(i)*ones(1, numOfParams);
    pm(i) = p(i) - h(i);
    P.(listOfParams{i}) = [pp, pm];
    twoSteps(i) = pp(i) - pm(i);
end
thisWithSteps = assign(thisWithSteps, P);
thisWithSteps = solve(thisWithSteps);

% Simulate SRF for all parameterisations. Do not delog shock responses in
% `srf`; this will be done after differentiation.
[s, ~, ~, opt] = srf(thisWithSteps, time, varargin{:});

% For each simulation, divide the difference from baseline by the size of
% the step.
for i = find(ixy | ixx | ixe | ixg)
    name = this.Quantity.Name{i};
    x = s.(name).Data;  
    c = s.(name).Comment;
    numOfShocks = size(x, 2);
    dx = nan(size(x, 1), numOfShocks, numOfParams);
    dc = cell(1, numOfShocks, numOfParams);
    for j = 1 : numOfParams
        dx(:, :, j) = (x(:, :, j) - x(:, :, numOfParams+j)) / twoSteps(j);
        dc(1, :, j) = strcat(c(1, 1:numOfShocks, j), '/', listOfParams{j});
    end
    if opt.Delog && this.Quantity.IxLog(i)
        dx = real(exp(dx));
    end
    s.(name).Data = dx;
    s.(name).Comment = dc;
    s.(name) = trim(s.(name));
end

s = addToDatabank('Default', this, s);

end%

