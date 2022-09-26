function [CC, RR, solutionVector] = acf(this, varargin)

persistent pp
if isempty(pp)
    pp = extend.InputParser('model.acf');
    addRequired(pp, 'Model', @(x) isa(x, 'model'));

    addParameter(pp, 'NFreq', 256, @(x) isnumeric(x) && isscalar(x) && x==round(x) && x>0);
    addParameter(pp, {'Contributions', 'Contribution'}, false, @(x) isequal(x, true) || isequal(x, false));
    addParameter(pp, 'Order', 0, @(x) isnumeric(x) && isscalar(x) && x==round(x) && x>=0);
    addParameter(pp, 'MatrixFormat', 'NamedMatrix', @validate.matrixFormat);
    addParameter(pp, 'Select', @all, @(x) (isequal(x, @all) || iscellstr(x) || ischar(x) || isa(x, 'string')) && ~isempty(x));
    addParameter(pp, 'ApplyTo', @all, @(x) isequal(x, @all) || iscellstr(x) || isa(x, 'string'));
    addParameter(pp, 'Filter', '', @(x) ischar(x) || isstring(x));
    addParameter(pp, 'SystemProperty', false, @(x) isequal(x, false) || ((ischar(x) || isa(x, 'string') || iscellstr(x)) && ~isempty(x)));
    addParameter(pp, 'Progress', false, @(x) isequal(x, true) || isequal(x, false));
end
parse(pp, this, varargin{:});
opt = pp.Options;

isSelect = ~isequal(opt.Select, @all);
isNamedMat = any(strcmpi(opt.MatrixFormat, {'NamedMatrix', 'NamedMat'}));
isContributions = opt.Contributions;
isCorrelations = nargout>=2;

%--------------------------------------------------------------------------

[ny, nxi, ~, ~, ne] = sizeSolution(this.Vector);
nv = length(this);

if isContributions
    numContributions = ne;
else
    numContributions = 1;
end

% Pre-process filter options
solutionVector = printSolutionVector(this, 'yx', @Behavior);
[isFilter, filter, freq, applyFilterTo] = freqdom.applyfilteropt(opt, [ ], solutionVector);

% Set up SystemProperty
systemProperty = hereSetupSystemProperty( );
if ~isequal(opt.SystemProperty, false)
    CC = systemProperty;
    return
end

[CC, RR] = herePreallocateOutputArrays( );

inxNaNSolutions = reportNaNSolutions(this);

if opt.Progress
    progress = ProgressBar('[IrisToolbox] @Model/acf Progress');
end


% /////////////////////////////////////////////////////////////////////////
for v = find(~inxNaNSolutions)
    update(systemProperty, this, v);
    covfun.wrapper(this, systemProperty, v);
    if isContributions
        CC(:, :, :, :, v) = systemProperty.Outputs{1};
        if isCorrelations
            RR(:, :, :, :, v) = systemProperty.Outputs{2};
        end
    else
        CC(:, :, :, v) = systemProperty.Outputs{1};
        if isCorrelations
            RR(:, :, :, v) = systemProperty.Outputs{2};
        end
    end
    if opt.Progress
        update(progress, v, ~inxNaNSolutions);
    end
end
% /////////////////////////////////////////////////////////////////////////


% Select submatrices if requested
if isSelect
    [CC, pos] = namedmat.myselect(CC, solutionVector, solutionVector, opt.Select, opt.Select);
    pos = pos{1};
    solutionVector = solutionVector(pos);
    if isCorrelations
        RR = RR(pos, pos, :, :, :);
    end
end

% Convert double arrays to namedmat objects if requested
if isNamedMat
    CC = namedmat(CC, solutionVector, solutionVector);
    if isCorrelations
        RR = namedmat(RR, solutionVector, solutionVector);
    end
end

return


    function systemProperty = hereSetupSystemProperty( )
        systemProperty = SystemProperty(this);
        systemProperty.Function = @covfun.wrapper;
        systemProperty.MaxNumOfOutputs = 2;
        systemProperty.NamedReferences = {solutionVector, solutionVector};
        systemProperty.CallerData = struct( );
        systemProperty.CallerData.MaxOrder = opt.Order;
        systemProperty.CallerData.IsContributions = isContributions;
        systemProperty.CallerData.IsCorrelations = isCorrelations;
        systemProperty.CallerData.NumContributions = numContributions;
        systemProperty.CallerData.IsFilter = isFilter;
        systemProperty.CallerData.Filter = filter;
        systemProperty.CallerData.ApplyFilterTo = applyFilterTo;
        systemProperty.CallerData.Frequencies = freq;
        if isequal(opt.SystemProperty, false)
            % Regular call
            if ~isCorrelations
                systemProperty.OutputNames = { 'CC' };
            else
                systemProperty.OutputNames = { 'CC', 'RR' };
            end
        else
            % Prepare for SystemProperty calls
            systemProperty.OutputNames = opt.SystemProperty;
        end
        preallocateOutputs(systemProperty);
    end%


    function [CC, RR] = herePreallocateOutputArrays( )
        if isContributions
            CC = nan(ny+nxi, ny+nxi, opt.Order+1, numContributions, nv);
        else
            CC = nan(ny+nxi, ny+nxi, opt.Order+1, nv);
        end
        RR = double.empty(0);
        if isCorrelations
            RR = nan(size(CC));
        end
    end%
end%

