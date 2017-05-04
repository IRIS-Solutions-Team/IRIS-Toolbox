function [F, list] = ffrf(this, freq, varargin)
% ffrf  Filter frequency response function of transition variables to measurement variables.
%
% Syntax
% =======
%
%     [F, List] = ffrf(M, Freq, ...)
%
%
% Input arguments
% ================
%
% * `M` [ model ] - Model object for which the frequency response function
% will be computed.
%
% * `Freq` [ numeric ] - Vector of frequencies for which the response
% function will be computed.
%
%
% Output arguments
% =================
%
% * `F` [ namedmat | numeric ] - Array with frequency responses of
% transition variables (in rows) to measurement variables (in columns).
%
% * `List` [ cell ] - List of transition variables in rows of the `F`
% matrix, and list of measurement variables in columns of the `F` matrix.
%
%
% Options
% ========
%
% * `'include='` [ char | cellstr | *`@all`* ] - Include the effect of the
% listed measurement variables only; `@all` means all measurement
% variables.
%
% * `'exclude='` [ char | cellstr | *empty* ] - Remove the effect of the
% listed measurement variables.
%
% * `'maxIter='` [ numeric | *500* ] - Maximum number of iteration when
% computing the steady-state Kalman filter.
%
% * `'matrixFmt='` [ *`'namedmat'`* | `'plain'` ] - Return matrix `F` as
% either a [`namedmat`](namedmat/Contents) object (i.e. matrix with named
% rows and columns) or a plain numeric array.
%
% * `'select='` [ *`@all`* | char | cellstr ] - Return FFRF for selected
% variables only; `@all` means all variables.
%
% * `'tolerance='` [ numeric | *`1e-7`* ] - Convergence tolerance when
% computing the steady-state Kalman filter.
%
%
% Description
% ============
%
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

TYPE = @int8;

% Parse input arguments.
pp = inputParser( );
pp.addRequired('Freq', @isnumeric);
pp.parse(freq);

% Parse options.
opt = passvalopt('model.ffrf', varargin{:});

[ny, nxx] = sizeOfSolution(this.Vector);
ixy = this.Quantity.Type==TYPE(1);

if isequal(opt.include, @all) && ~isempty(opt.exclude)
    opt.include = this.Quantity.Name(ixy);
elseif ischar(opt.include)
    opt.include = regexp(opt.include, '\w+', 'match');
end

if ischar(opt.exclude)
    opt.exclude = regexp(opt.exclude, '\w+', 'match');
end

if ~isempty(opt.exclude) && ~isequal(opt.include, @all)
    utils.error('model:ffrf', ...
        'Options ''include='' and ''exclude='' cannot be combined.');
end

isSelect = ~isequal(opt.select, @all);
isNamedMat = strcmpi(opt.MatrixFmt, 'namedmat');

% TODO: Implement the `'exclude='` option through the `'select='` option.

%--------------------------------------------------------------------------

nAlt = length(this);

% Index of the measurement variables included.
if isequal(opt.include, @all)
    ixInclude = true(1, ny);
else
    [~, ixInclude] = userSelection2Index( ...
        this.Quantity, ...
        setdiff(opt.include, opt.exclude), ...
        TYPE(1) ...
        );
end

freq = freq(:)';
nFreq = length(freq);
F = nan(nxx, ny, nFreq, nAlt);

if ny>0 && any(ixInclude)
    getFfrf( );
else
    utils.warning('model:ffrf', ...
        'No measurement variables included in calculation of FFRF.');
end

if nargout<=1 && ~isSelect && ~isNamedMat
    return
end

% List of variables in rows and columns of `F`.
rowNames = printSolutionVector(this, 'x');
colNames = printSolutionVector(this, 'y');

% Select requested variables if requested.
if isSelect
    [F, pos] = namedmat.myselect(F, rowNames, colNames, opt.select);
    rowNames = rowNames(pos{1});
    colNames = colNames(pos{2});
end
list = {rowNames, colNames};

if true % ##### MOSW
    % Convert output matrix to namedmat object if requested.
    if isNamedMat
        F = namedmat(F, rowNames, colNames);
    end
else
    % Do nothing.
end

return

    
    
    
    function getFfrf( )
        [flag, ixNanAlt] = isnan(this, 'solution');
        for iAlt = find(~ixNanAlt)
            nUnit = sum(this.Variant{iAlt}.Stability==TYPE(1));
            [T, R, ~, Z, H, ~, U, Omg] = sspaceMatrices(this, iAlt, false);
            % Compute FFRF.
            F(:, :, :, iAlt) = freqdom.ffrf3( ...
                T, R, [ ], Z, H, [ ], U, Omg, nUnit, ...
                freq, ixInclude, opt.tolerance, opt.maxiter);
        end
        % Solution not available.
        if flag
            utils.warning('model:ffrf', ...
                'Solution not available %s.', ...
                exception.Base.alt2str(ixNanAlt) );
        end
    end


end
