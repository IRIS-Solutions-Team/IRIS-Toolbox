function varargout = ffrf(this, freq, varargin)
% ffrf  Filter frequency response function of transition variables to measurement variables
%{
% ## Syntax ##
%
%
%     [F, list] = ffrf(model, freq, ...)
%
%
% ## Input Arguments ##
%
%
% __`model`__ [ Model ]
% >
% Model object for which the frequency response function
% will be computed.
%
%
% __`freq`__ [ numeric ]
% >
% Vector of freq for which the response
% function will be computed.
%
%
% ## Output Arguments ##
%
% __`F`__ [ namedmat | numeric ]
% >
% Array with frequency responses of transition variables (in rows) to
% measurement variables (in columns).
%
%
% __`list`__ [ cell ]
% >
% List of transition variables in rows of the `F` matrix, and list of
% measurement variables in columns of the `F` matrix.
%
%
% ## Options ##
%
%
% __`Include=@all`__ [ char | cellstr | `@all` ]
% >
% Include the effect of the listed measurement variables only; `@all` means
% all measurement variables.
%
%
% __`Exclude=[ ]`__ [ char | cellstr | empty ]
% >
% Remove the effect of the
% listed measurement variables.
%
%
% __`MaxIter=500`__ [ numeric ]
% >
% Maximum number of iteration when
% calculating a steady-state Kalman filter for zero-frequency FRF.
%
%
% __`MatrixFormat='NamedMat'`__ [ `'NamedMat'` | `'Plain'` ]
% >
% Return matrix
% `F` as either a [`namedmat`](namedmat/Contents) object (i.e. matrix with
% named rows and columns) or a plain numeric array.
%
%
% __`Select=@all`__ [ `@all` | char | cellstr ]
% >
% Return FFRF for selected variables only; `@all` means all variables.
%
%
% __`Tolerance=1e-7`__ [ numeric ]
% >
% Convergence tolerance when calculating a steady-state Kalman filter for
% zero-frequency FRF.
%
%
% ## Description ##
%
%
% ## Example ##
%
%}

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 IRIS Solutions Team

TYPE = @int8;

persistent parser
if isempty(parser)
    parser = extend.InputParser('model.ffrf');
    parser.addRequired('model', @(x) isa(x, 'model'));
    parser.addRequired('freq', @isnumeric);
    parser.addParameter({'Include', 'Select'}, cell.empty(1, 0), @(x) isempty(x) || isequal(x, @all) || ischar(x) || isa(x, 'string') || iscellstr(x));
    parser.addParameter('Exclude', cell.empty(1, 0), @(x) isempty(x) || ischar(x) || isa(x, 'string') || iscellstr(x));
    parser.addParameter('MatrixFormat', 'namedmat', @namedmat.validateMatrixFormat);
    parser.addParameter('MaxIter', 500, @(x) isempty(x) || (isnumeric(x) && isscalar(x) && x>=0));
    parser.addParameter('Tolerance', 1e-7, @(x) isempty(x) || (isnumeric(x) && isscalar(x) && x>0));
    parser.addParameter('SystemProperty', false, @(x) isequal(x, false) || ((ischar(x) || isa(x, 'string') || iscellstr(x)) && ~isempty(x)));
end
parse(parser, this, freq, varargin{:});
opt = parser.Options;
usingDefaults = parser.UsingDefaultsInStruct;

isNamedMat = strcmpi(opt.MatrixFormat, 'namedmat');

%--------------------------------------------------------------------------

nv = length(this);
[ny, nxi] = sizeOfSolution(this.Vector);

assert( usingDefaults.Include || usingDefaults.Exclude, ...
        'model:ffrf:CannotCombineSelectExclude', ...
        'Options Select= and Exclude= cannot be combined.' );

ixy = this.Quantity.Type==TYPE(1);
selectedNames = this.Quantity.Name(ixy);
if usingDefaults.Include && usingDefaults.Exclude
    % Neither Exclude= nor Select= (Include=)
    inxToInclude = true(1, ny);
else
    % Exclude= option
    if usingDefaults.Include 
        inxToExclude = ismember(selectedNames, opt.Exclude);
        inxToInclude = ~inxToExclude;
    else
        % Select= (or Include=) option
        inxToInclude = ismember(selectedNames, opt.Include);
    end
end
solutionVectorX = printSolutionVector(this, 'x', @Behavior);
solutionVectorY = printSolutionVector(this, 'y', @Behavior);

% _System Property_
systemProperty = hereSetupSystemProperty( );
if ~isequal(opt.SystemProperty, false)
    varargout = { systemProperty };
    return
end

numFreq = numel(systemProperty.Specifics.Frequencies);
F = complex(nan(nxi, ny, numFreq, nv), nan(nxi, ny, numFreq, nv));


% /////////////////////////////////////////////////////////////////////////
if ny>0 && any(inxToInclude)
    indexOfNaNSolutions = reportNaNSolutions(this);
    for v = find(~indexOfNaNSolutions)
        update(systemProperty, this, v);
        freqdom.ffrf3(this, systemProperty, v);
        F(:, :, :, v) = systemProperty.Outputs{1};
    end
end
% /////////////////////////////////////////////////////////////////////////


% Convert output matrix to namedmat object if requested
if isNamedMat
    F = namedmat(F, solutionVectorX, solutionVectorY);
end
varargout = cell(1, 3);
varargout{1} = F;
varargout{2} = {solutionVectorX, solutionVectorY};

return

    
    function systemProperty = hereSetupSystemProperty( )
        systemProperty = SystemProperty(this);
        systemProperty.Function = @freqdom.ffrf3;
        systemProperty.MaxNumOfOutputs = 1;
        systemProperty.NamedReferences = {solutionVectorX, solutionVectorY};
        systemProperty.Specifics.IndexToInclude = inxToInclude;
        systemProperty.Specifics.MaxIter = opt.MaxIter;
        systemProperty.Specifics.Frequencies = freq(:)';
        systemProperty.Specifics.Tolerance = opt.Tolerance;
        if isequal(opt.SystemProperty, false)
            % Regular call
            systemProperty.OutputNames = { 'FF' };
        else
            % Prepare for SystemProperty calls
            systemProperty.OutputNames = opt.SystemProperty;
        end
        preallocateOutputs(systemProperty);
    end%
end%
