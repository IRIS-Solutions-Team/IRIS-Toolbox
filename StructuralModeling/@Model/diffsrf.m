%{
% 
% # `diffsrf` ^^(Model)^^
% 
% {== Differentiate shock response functions w.r.t. specified parameters ==}
% 
% 
% ## Syntax 
% 
%     outputDatabank = diffsrf(model, numOfPeriods, listOfParams, ...)
%     outputDatabank = diffsrf(model, range, listOfParams, ...)
% 
% ## Input arguments 
% 
%  `model` [ model ]
% >
% > Model object whose response functions will be
% > simulated and differentiated.
% >
% 
%  `range` [ numeric | char ] 
% >
% > Simulation date range with the first date
% > being the shock date.
% >
% 
%  `numOfPeriods` [ numeric ] 
% > 
% > Number of simulation periods.
% > 
% 
%  `listOfParams` [ char | cellstr ] 
% >
% > List of parameters w.r.t. which the
% > shock response functions will be differentiated.
% >
% 
% ## Output arguments 
% 
% 
%     `outputDatabank` [ struct ]
% > 
% > Database with shock reponse derivatives 
% > returned in multivariate time series.
% >
% 
% 
% ## Options 
% 
% > 
% > See [`model/srf`](model/srf) for options available
% > 
% ## Description 
% 
% 
% 
% ## Examples
% 
% 
%}
% --8<--


function [s, this] = diffsrf(this, time, listParams, varargin)

% Convert char list to cellstr.
if ischar(listParams)
    listParams = regexp(listParams, '\w+', 'match');
end

%--------------------------------------------------------------------------

nv = length(this);
ixy = this.Quantity.Type==1;
ixx = this.Quantity.Type==2;
ixe = this.Quantity.Type==31 | this.Quantity.Type==32;
ixg = this.Quantity.Type==5;

if nv>1
    THIS_ERROR = { 'Model:CannotRunMultipleVariants'
                   'Cannot run diffsrf(~) on model objects with multiple parameter variants' };
    throw( exception.Base(THIS_ERROR, 'error') );
end

ell = lookup(this.Quantity, listParams, 4);
posParams = ell.PosName;
indexOfValidNames = ~isnan(posParams);
if any(~indexOfValidNames)
    throw( exception.Base('Model:INVALID_NAME', 'error'), ...
           'parameter ', listParams{indexOfValidNames} ); %#ok<GTARG>
end

% Find optimal step for two-sided derivatives
p = this.Variant.Values(1, posParams);
numParams = numel(posParams);
h = eps^(1/3) * max([p; ones(size(p))], [ ], 1);

% Assign alternative parameterisations p(i)+h(i) and p(i)-h(i)
thisWithSteps = alter(this, 2*numParams);
P = struct( );
twoSteps = nan(1, numParams);
for i = 1 : numParams
    pp = repmat(p(i), 1, numParams);
    pp(i) = p(i) + h(i);
    pm = repmat(p(i), 1, numParams);
    pm(i) = p(i) - h(i);
    P.(listParams{i}) = [pp, pm];
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
    numShocks = size(x, 2);
    newData = nan(size(x, 1), numShocks, numParams);
    newComment = strings(1, numShocks, numParams);
    for j = 1 : numParams
        newData(:, :, j) = (x(:, :, j) - x(:, :, numParams+j)) / twoSteps(j);
        newComment(1, :, j) = c(1, 1:numShocks, j) + "/" + string(listParams{j});
    end
    if opt.Delog && this.Quantity.IxLog(i)
        newData = real(exp(newData));
    end
    s.(name).Data = newData;
    s.(name).Comment = newComment;
    s.(name) = trim(s.(name));
end

s = addToDatabank("Default", this, s);

end%

