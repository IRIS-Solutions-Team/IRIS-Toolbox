function varargout = ffrf(this, frequencies, varargin)
% ffrf  Filter frequency response function of transition variables to measurement variables
%
% __Syntax__
%
%     [F, List] = ffrf(M, Freq, ...)
%
%
% __Input Arguments__
%
% * `M` [ model ] - Model object for which the frequency response function
% will be computed.
%
% * `Freq` [ numeric ] - Vector of frequencies for which the response
% function will be computed.
%
%
% __Output Arguments__
%
% * `F` [ namedmat | numeric ] - Array with frequency responses of
% transition variables (in rows) to measurement variables (in columns).
%
% * `List` [ cell ] - List of transition variables in rows of the `F`
% matrix, and list of measurement variables in columns of the `F` matrix.
%
%
% __Options__
%
% * `'Include='` [ char | cellstr | *`@all`* ] - Include the effect of the
% listed measurement variables only; `@all` means all measurement
% variables.
%
% * `'Exclude='` [ char | cellstr | *empty* ] - Remove the effect of the
% listed measurement variables.
%
% * `'MaxIter='` [ numeric | *`500`* ] - Maximum number of iteration when
% calculating a steady-state Kalman filter for zero-frequency FRF.
%
% * `'MatrixFormat='` [ *`'namedmat'`* | `'plain'` ] - Return matrix `F` as
% either a [`namedmat`](namedmat/Contents) object (i.e. matrix with named
% rows and columns) or a plain numeric array.
%
% * `'Select='` [ *`@all`* | char | cellstr ] - Return FFRF for selected
% variables only; `@all` means all variables.
%
% * `'Tolerance='` [ numeric | *`1e-7`* ] - Convergence tolerance when
% calculating a steady-state Kalman filter for zero-frequency FRF.
%
%
% __Description__
%
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

TYPE = @int8;

persistent INPUT_PARSER
if isempty(INPUT_PARSER)
    INPUT_PARSER = extend.InputParser('model.ffrf');
    INPUT_PARSER.addRequired('Model', @(x) isa(x, 'model'));
    INPUT_PARSER.addRequired('Freq', @isnumeric);
    INPUT_PARSER.addParameter({'Include', 'Select'}, cell.empty(1, 0), @(x) isempty(x) || isequal(x, @all) || ischar(x) || isa(x, 'string') || iscellstr(x));
    INPUT_PARSER.addParameter('Exclude', cell.empty(1, 0), @(x) isempty(x) || ischar(x) || isa(x, 'string') || iscellstr(x));
    INPUT_PARSER.addParameter('MatrixFormat', 'namedmat', @namedmat.validateMatrixFormat);
    INPUT_PARSER.addParameter('MaxIter', 500, @(x) isempty(x) || (isnumeric(x) && isscalar(x) && x>=0));
    INPUT_PARSER.addParameter('Tolerance', 1e-7, @(x) isempty(x) || (isnumeric(x) && isscalar(x) && x>0));
    INPUT_PARSER.addParameter({'SystemProperty', 'PrepareOnly'}, false, @(x) isequal(x, true) || isequal(x, false));
end
INPUT_PARSER.parse(this, frequencies, varargin{:});
opt = INPUT_PARSER.Options;
usingDefaults = INPUT_PARSER.UsingDefaultsInStruct;

isNamedMat = strcmpi(opt.MatrixFormat, 'namedmat');

%--------------------------------------------------------------------------

nv = length(this);
[ny, nxi] = sizeOfSolution(this.Vector);

assert( ...
    usingDefaults.Include || usingDefaults.Exclude, ...
    'model:ffrf:CannotCombineSelectExclude', ...
    'Options Select= and Exclude= cannot be combined.' ...
);

ixy = this.Quantity.Type==TYPE(1);
selectedYNames = this.Quantity.Name(ixy);
if usingDefaults.Include && usingDefaults.Exclude
    % Neither Exclude= nor Select= (Include=)
    indexToInclude = true(1, ny);
else
    % Exclude= option
    if usingDefaults.Include 
        indexToExclude = ismember(selectedYNames, opt.Exclude);
        indexToInclude = ~indexToExclude;
    else
        % Select= (or Include=) option
        indexToInclude = ismember(selectedYNames, opt.Include);
    end
end
solutionVectorX = printSolutionVector(this, 'x', @Behavior);
solutionVectorY = printSolutionVector(this, 'y', @Behavior);

systemProperty = createSystemPropertyObject( );

if opt.SystemProperty
    varargout = cell(1, 1);
    varargout{1} = systemProperty;
    return
end

numFreq = numel(systemProperty.Specifics.Frequencies);
F = complex(nan(nxi, ny, numFreq, nv), nan(nxi, ny, numFreq, nv));
count = nan(1, nv);

if ny>0 && any(indexToInclude)
    indexNaNSolutions = reportNaNSolutions(this);
    for v = find(~indexNaNSolutions)
        update(systemProperty, this, v);
        [vthF, vthCount] = freqdom.ffrf3(systemProperty);
        F(:, :, :, v) = vthF;
        count(1, v) = vthCount;
    end
end

% Convert output matrix to namedmat object if requested
if isNamedMat
    F = namedmat(F, solutionVectorX, solutionVectorY);
end
varargout = cell(1, 3);
varargout{1} = F;
varargout{2} = {solutionVectorX, solutionVectorY};
varargout{3} = count;

return

    
    function systemProperty = createSystemPropertyObject( )
        systemProperty = SystemProperty(this);
        systemProperty.Function = @freqdom.ffrf3;
        systemProperty.MaxNumOutputs = 1;
        systemProperty.NamedReferences = {solutionVectorX, solutionVectorY};
        systemProperty.Specifics.IndexToInclude = indexToInclude;
        systemProperty.Specifics.MaxIter = opt.MaxIter;
        systemProperty.Specifics.Frequencies = frequencies(:)';
        systemProperty.Specifics.Tolerance = opt.Tolerance;
    end
end
