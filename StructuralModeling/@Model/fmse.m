%{
% 
% # `fmse` ^^(Model)^^
% 
% {== Forecast mean square error matrices. ==}
% 
% 
% ## Syntax 
% 
%     [F, List, D] = fmse(M, NPer, ...)
%     [F, List, D] = fmse(M, range, ...)
% 
% 
% ## Input arguments 
% 
%   `M` [ model ]
% >
% > Model object for which the forecast MSE matrices will
% > be computed.
% >
% 
%   `NPer` [ numeric ] 
% >  
% >  Number of periods.
% >
% 
%   `range` [ numeric | char ] 
% >  
% >  Date range.
% >
% 
%  ## Output Arguments
% 
%   `F` [ namedmat | numeric ]
% >
% > Forecast MSE matrices.
% >
% 
%   `List` [ cellstr ]
% >  
% > List of variables in rows and columns of `M`.
% >
% 
%   `D` [ dbase ]
% >
% > Database with the std deviations of individual variables,
% > i.e. the square roots of the diagonal elements of `F`.
% >
% 
%  ## Options ##
% 
%   `'MatrixFormat='` [ `'namedmat'` | `'plain'` ]
% >
% > Return matrix `F` as
% > either a [`namedmat`](namedmat/Contents) object (i.e. matrix with named
% > rows and columns) or a plain numeric array.
% >
% 
%   `'Select='` [ `@all` | char | cellstr ]
% >  
% > Return FMSE for selected
% > variables only; `@all` means all variables.
% >
% 
% 
% ## Description 
% 
% 
% 
% ## Examples
% 
% 
%}
% --8<--


function [X, YXVec, stdDb] = fmse(this, time, varargin)

persistent ip
if isempty(ip)
    ip = extend.InputParser();
    ip.addRequired('Model', @(x) isa(x, 'model'));
    ip.addRequired('Time', @validate.date);
end
ip.parse(this, time);


defaults = {
    'MatrixFormat', 'namedmat', @validate.matrixFormat
    'select', @all, @(x) (isequal(x, @all) || iscellstr(x) || ischar(x)) && ~isempty(x)
};

opt = passvalopt(defaults, varargin{:});


% tell whether time is nper or range
if isscalar(time) && round(time)==time && time>0
    time = 1 : time;
end
range = time(1) : time(end);
nPer = numel(range);

isSelect = ~isequal(opt.select, @all);
isNamedMat = strcmpi(opt.MatrixFormat, 'namedmat');

%--------------------------------------------------------------------------

[ny, nxx] = sizeSolution(this.Vector);
nv = length(this);
X = zeros(ny+nxx, ny+nxx, nPer, nv);

indexOfSolutionsAvailable = beenSolved(this);
for v = find(indexOfSolutionsAvailable)
    [T, R, K, Z, H, D, U, Omg] = getSolutionMatrices(this, v, false);
    X(:, :, :, v) = timedom.fmse(T, R, K, Z, H, D, U, Omg, nPer);
end

% Report variants with solutions not available.
assert( ...
    all(indexOfSolutionsAvailable), ...
    exception.Base('Model:SolutionNotAvailable', 'error'), ...
    exception.Base.alt2str(~indexOfSolutionsAvailable) ...
);

% Database of std deviations.
if nargout>2
    % Select only contemporaneous variables.
    id = [this.Vector.Solution{1:2}];
    dbStd = struct( );
    for i = find(imag(id)==0)
        name = this.Quantity.Name{id(i)};
        stdDb.(name) = Series( ...
            range, ...
            sqrt( permute(X(i, i, :, :), [3, 4, 1, 2]) ) ...
        );
    end
    stdDb = addToDatabank({'Parameters', 'Std', 'NonzeroCorr'}, this, stdDb);
end

if nargout<=1 && ~isSelect && ~isNamedMat
    return
end

YXVec = printSolutionVector(this, 'yx');

% Select variables if requested.
if isSelect
    [X, pos] = namedmat.myselect(X, YXVec, YXVec, opt.select);
    pos = pos{1};
    YXVec = YXVec(pos);
end

% Convert output matrix to namedmat object if requested.
if isNamedMat
    X = namedmat(X, YXVec, YXVec);
end

end
