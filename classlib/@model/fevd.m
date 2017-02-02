function [X, Y, lsName, dbAbs, dbRel] = fevd(this, time, varargin)
% fevd  Forecast error variance decomposition for model variables.
%
% Syntax
% =======
%
%     [X, Y, List, A, B] = fevd(M, Range, ...)
%     [X, Y, List, A, B] = fevd(M, NPer, ...)
%
% Input arguments
% ================
%
% * `M` [ model ] - Model object for which the decomposition will be
% computed.
%
% * `Range` [ numeric | char ] - Decomposition date range with the first
% date beign the first forecast period.
%
% * `NPer` [ numeric ] - Number of periods for which the decomposition will
% be computed.
%
% Output arguments
% =================
%
% * `X` [ namedmat | numeric ] - Array with the absolute contributions of
% individual shocks to total variance of each variables.
%
% * `Y` [ namedmat | numeric ] - Array with the relative contributions of
% individual shocks to total variance of each variables.
%
% * `List` [ cellstr ] - List of variables in rows of the `X` an `Y`
% arrays, and shocks in columns of the `X` and `Y` arrays.
%
% * `A` [ struct ] - Database with the absolute contributions converted to
% time series.
%
% * `B` [ struct ] - Database with the relative contributions converted to
% time series.
%
% Options
% ========
%
% * `'matrixFmt='` [ *`'namedmat'`* | `'plain'` ] - Return matrices `X`
% and `Y` as be either [`namedmat`](namedmat/Contents) objects (i.e.
% matrices with named rows and columns) or plain numeric arrays.
%
% * `'select='` [ `@all` | char | cellstr ] - Return FEVD for selected
% variables and/or shocks only; `@all` means all variables and shocks; this
% option does not apply to the output databases, `A` and `B`.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

pp = inputParser( );
pp.addRequired('M', @(x) isa(x, 'model'));
pp.addRequired('Time', @(x) isdatinp(x));
pp.parse(this, time);

% Parse options.
opt = passvalopt('model.fevd', varargin{:});

% Tell whether time is nPer or Range.
if ischar(time)
    time = textinp2dat(time);
elseif length(time) == 1 && round(time) == time && time > 0
    time = 1 : time;
end
Range = time(1) : time(end);
nPer = length(Range);

isSelect = ~isequal(opt.select, @all);
isNamedMat = strcmpi(opt.MatrixFmt, 'namedmat');

%--------------------------------------------------------------------------

[ny, nxx, ~, ~, ne] = sizeOfSolution(this.Vector);
nAlt = length(this);
X = nan(ny+nxx, ne, nPer, nAlt);
Y = nan(ny+nxx, ne, nPer, nAlt);

ixZeroCorr = true(1, nAlt);
ixSolved = true(1, nAlt);
for iAlt = 1 : nAlt
    
    % Continue immediately if some cross-corrs are non-zero.
    ixZeroCorr(iAlt) = all(this.Variant{iAlt}.StdCorr(1, ne+1:end)==0);
    if ~ixZeroCorr(iAlt)
        continue
    end
    
    [T, R, K, Z, H, D, Za, Omg] = mysspace(this, iAlt, false);
    
    % Continue immediately if solution is not available.
    ixSolved(iAlt) = all(~isnan(T(:)));
    if ~ixSolved(iAlt)
        continue
    end
    
    [Xi, Yi] = timedom.fevd(T, R, K, Z, H, D, Za, Omg, nPer);
    X(:, :, :, iAlt) = Xi;
    Y(:, :, :, iAlt) = Yi;
end

% Report NaN solutions.
if ~all(ixSolved)
    utils.warning('model:fevd', ...
        'Solution(s) not available %s.', ...
        exception.Base.alt2str(~ixSolved) );
end

% Report non-zero cross-correlations.
if ~all(ixZeroCorr)
    utils.warning('model:fevd', ...
        ['Cannot compute FEVD with ', ...
        'nonzero cross-correlations %s.'], ...
        exception.Base.alt2str(~ixZeroCorr) );
end

if nargout <= 2 && ~isSelect && ~isNamedMat
    return
end

rowNames = printSolutionVector(this, 'yx');
colNames = printSolutionVector(this, 'e');

% Convert arrays to time series databases.
if nargout > 3
    % Select only current dated variables.
    id = [this.Vector.Solution{1:2}];
    name = this.Quantity.Name(real(id));

    dbAbs = struct( );
    dbRel = struct( );
    for i = find(imag(id) == 0)
        c = strcat(rowNames{i}, ' <-- ', colNames);
        dbAbs.(name{i}) = Series(Range, permute(X(i, :, :, :), [3, 2, 4, 1]), c);
        dbRel.(name{i}) = Series(Range, permute(Y(i, :, :, :), [3, 2, 4, 1]), c);
    end
    % Add parameter database.
    dbAbs = addparam(this, dbAbs);
    dbRel = addparam(this, dbRel);
end

% Select variables if requested; selection only applies to the matrix
% outputs, `X` and `Y`, and not to the database outputs, `x` and `y`.
if isSelect
    [X, pos] = namedmat.myselect(X, rowNames, colNames, opt.select);
    rowNames = rowNames(pos{1});
    colNames = colNames(pos{2});
    if nargout > 1
        Y = Y(pos{1}, pos{2}, :, :);
    end
end
lsName = {rowNames, colNames};

if true % ##### MOSW
    % Convert output matrices to namedmat objects if requested.
    if isNamedMat
        X = namedmat(X, rowNames, colNames);
        if nargout > 1
            Y = namedmat(Y, rowNames, colNames);
        end
    end
else
    % Do nothing.
end

end
