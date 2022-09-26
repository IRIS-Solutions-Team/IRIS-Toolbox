%{
% 
% # `fevd` ^^(Model)^^
% 
% {== Forecast error variance decomposition for model variables.==}
% 
% 
% ## Syntax 
% 
%     [X, Y, List, A, B] = fevd(M, Range, ...)
%     [X, Y, List, A, B] = fevd(M, NPer, ...)
% 
% 
%  ## Input Arguments
% 
%   `M` [ model ] 
% >
% > Model object for which the decomposition will be
% > computed.
% >
% 
%   `Range` [ numeric | char ] 
% >  
% > Decomposition date range with the first
% > date beign the first forecast period.
% >
% 
%   `NPer` [ numeric ] 
% >  
% > Number of periods for which the decomposition will
% > be computed.
% >
% 
%  ## Output Arguments
% 
%   `X` [ namedmat | numeric ]
% >  
% > Array with the absolute contributions of
% > individual shocks to total variance of each variables.
% >
% 
%   `Y` [ namedmat | numeric ]
% >  
% > Array with the relative contributions of
% > individual shocks to total variance of each variables.
% >
% 
%   `List` [ cellstr ] 
% >  
% > List of variables in rows of the `X` an `Y`
% > arrays, and shocks in columns of the `X` and `Y` arrays.
% >
% 
%   `A` [ struct ]
% >  
% > Database with the absolute contributions converted to
% > time series.
% >
% 
%   `B` [ struct ] 
% >  
% > Database with the relative contributions converted to
% > time series.
% >
% 
%  ## Options
% 
%  `'MatrixFormat='` [ `'namedmat'` | `'plain'` ] 
% > 
% > Return matrices `X`
% > and `Y` as be either [`namedmat`](namedmat/Contents) objects (i.e.
% > matrices with named rows and columns) or plain numeric arrays.
% >
% 
%   `'select='` [ `@all` | char | cellstr ]
% >  
% > Return FEVD for selected
% > variables and/or shocks only; `@all` means all variables and shocks; this
% > option does not apply to the output databases, `A` and `B`.
% >
% 
%  ## Description
% 
% 
%  ## Examples
% 
%}
% --8<--


function [X, Y, lsName, dbAbs, dbRel] = fevd(this, time, varargin)

persistent ip
if isempty(ip)
    ip = extend.InputParser('model/fevd');
    ip.addRequired('Model', @(x) isa(x, 'model'));
    ip.addRequired('Time', @validate.date);
    ip.addParameter('MatrixFormat', 'namedmat', @validate.matrixFormat);
    ip.addParameter('Select', @all, @(x) (isequal(x, @all) || iscellstr(x) || ischar(x)) && ~isempty(x));
end
ip.parse(this, time, varargin{:});
opt = ip.Options;

% Tell whether time is numPeriods or Range.
if isscalar(time) && round(time)==time && time>0
    time = 1 : time;
end
range = time(1) : time(end);
numPeriods = numel(range);

isSelect = ~isequal(opt.Select, @all);
isNamedMat = strcmpi(opt.MatrixFormat, 'namedmat');

%--------------------------------------------------------------------------

[ny, nxx, ~, ~, ne] = sizeSolution(this.Vector);
nv = length(this);
X = nan(ny+nxx, ne, numPeriods, nv);
Y = nan(ny+nxx, ne, numPeriods, nv);

inxOfZeroCorr = true(1, nv);
inxOfSolutionsAvailable = beenSolved(this);
for v = find(inxOfSolutionsAvailable)
    % Continue immediately if some cross-corrs are non-zero.
    inxOfZeroCorr(v) = all(this.Variant.StdCorr(1, ne+1:end, v)==0);
    if ~inxOfZeroCorr(v)
        continue
    end
    [T, R, K, Z, H, D, Za, Omg] = getSolutionMatrices(this, v, false);
    % Continue immediately if solution is not available.
    [Xi, Yi] = timedom.fevd(T, R, K, Z, H, D, Za, Omg, numPeriods);
    X(:, :, :, v) = Xi;
    Y(:, :, :, v) = Yi;
end

% Report NaN solutions.
if ~all(inxOfSolutionsAvailable)
    utils.warning('model:fevd', ...
        'Solution(s) not available %s.', ...
        exception.Base.alt2str(~inxOfSolutionsAvailable) );
end

% Report non-zero cross-correlations.
if ~all(inxOfZeroCorr)
    utils.warning('model:fevd', ...
        ['Cannot compute FEVD with ', ...
        'nonzero cross-correlations %s.'], ...
        exception.Base.alt2str(~inxOfZeroCorr) );
end

if nargout<=2 && ~isSelect && ~isNamedMat
    return
end

rowNames = printSolutionVector(this, 'yx');
colNames = printSolutionVector(this, 'e');

% Convert arrays to time series databases.
if nargout>3
    % Select only current dated variables.
    id = [this.Vector.Solution{1:2}];
    name = this.Quantity.Name(real(id));

    dbAbs = struct( );
    dbRel = struct( );
    for i = find(imag(id)==0)
        c = strcat(rowNames{i}, ' <-- ', colNames);
        dbAbs.(name{i}) = Series(range, permute(X(i, :, :, :), [3, 2, 4, 1]), c);
        dbRel.(name{i}) = Series(range, permute(Y(i, :, :, :), [3, 2, 4, 1]), c);
    end
    % Add parameter database.
    dbAbs = addToDatabank({'Parameters', 'Std', 'NonzeroCorr'}, this, dbAbs);
    dbRel = addToDatabank({'Parameters', 'Std', 'NonzeroCorr'}, this, dbRel);
end

% Select variables if requested; selection only applies to the matrix
% outputs, `X` and `Y`, and not to the database outputs, `x` and `y`.
if isSelect
    [X, pos] = namedmat.myselect(X, rowNames, colNames, opt.Select);
    rowNames = rowNames(pos{1});
    colNames = colNames(pos{2});
    if nargout > 1
        Y = Y(pos{1}, pos{2}, :, :);
    end
end
lsName = {rowNames, colNames};

% Convert output matrices to namedmat objects if requested.
if isNamedMat
    X = namedmat(X, rowNames, colNames);
    if nargout > 1
        Y = namedmat(Y, rowNames, colNames);
    end
end

end
