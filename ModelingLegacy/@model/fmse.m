function [X, YXVec, dbankOfStd] = fmse(this, time, varargin)
% fmse  Forecast mean square error matrices.
%
% ## Syntax ##
%
%     [F, List, D] = fmse(M, NPer, ...)
%     [F, List, D] = fmse(M, Range, ...)
%
%
% ## Input Arguments ##
%
% * `M` [ model ] - Model object for which the forecast MSE matrices will
% be computed.
%
% * `NPer` [ numeric ] - Number of periods.
%
% * `Range` [ numeric | char ] - Date range.
%
%
% ## Output Arguments ##
%
% * `F` [ namedmat | numeric ] - Forecast MSE matrices.
%
% * `List` [ cellstr ] - List of variables in rows and columns of `M`.
%
% * `D` [ dbase ] - Database with the std deviations of
% individual variables, i.e. the square roots of the diagonal elements of
% `F`.
%
%
% ## Options ##
%
% * `'MatrixFormat='` [ *`'namedmat'`* | `'plain'` ] - Return matrix `F` as
% either a [`namedmat`](namedmat/Contents) object (i.e. matrix with named
% rows and columns) or a plain numeric array.
%
% * `'Select='` [ *`@all`* | char | cellstr ] - Return FMSE for selected
% variables only; `@all` means all variables.
%
%
% ## Description ##
%
%
% ## Example ##
%

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 IRIS Solutions Team

TIME_SERIES_CONSTRUCTOR = iris.get('DefaultTimeSeriesConstructor');
TYPE = @int8;

persistent INPUT_PARSER
if isempty(INPUT_PARSER)
    INPUT_PARSER = extend.InputParser('model/fmse');
    INPUT_PARSER.addRequired('Model', @(x) isa(x, 'model'));
    INPUT_PARSER.addRequired('Time', @DateWrapper.validateDateInput);
end
INPUT_PARSER.parse(this, time);

opt = passvalopt('model.fmse', varargin{:});

% tell whether time is nper or range
if ischar(time)
    time = textinp2dat(time);
elseif length(time)==1 && round(time)==time && time>0
    time = 1 : time;
end
Range = time(1) : time(end);
nPer = length(Range);

isSelect = ~isequal(opt.select, @all);
isNamedMat = strcmpi(opt.MatrixFormat, 'namedmat');

%--------------------------------------------------------------------------

[ny, nxx] = sizeOfSolution(this.Vector);
nv = length(this);
X = zeros(ny+nxx, ny+nxx, nPer, nv);

indexOfSolutionsAvailable = beenSolved(this);
for v = find(indexOfSolutionsAvailable)
    [T, R, K, Z, H, D, U, Omg] = sspaceMatrices(this, v, false);
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
        dbankOfStd.(name) = TIME_SERIES_CONSTRUCTOR( ...
            Range, ...
            sqrt( permute(X(i, i, :, :), [3, 4, 1, 2]) ) ...
            );
    end
    dbankOfStd = addToDatabank({'Parameters', 'Std', 'NonzeroCorr'}, this, dbankOfStd);
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

if true % ##### MOSW
    % Convert output matrix to namedmat object if requested.
    if isNamedMat
        X = namedmat(X, YXVec, YXVec);
    end
else
    % Do nothing.
end

end
