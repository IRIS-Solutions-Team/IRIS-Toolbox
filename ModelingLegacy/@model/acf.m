function varargout = acf(this, varargin)
% acf  Autocovariance and autocorrelation function for model variables
%
% __Syntax__
%
%     [C, R, list] = acf(model, ...)
%
%
% __Input Arguments__
%
% * `model` [ model ] - A solved model object for which the autocorrelation
% function will be computed.
%
%
% __Output Arguments__
%
% * `C` [ namedmat | numeric ] - Covariance matrices.
%
% * `R` [ namedmat | numeric ] - Correlation matrices.
%
% * `list` [ cellstr ] - List of variables in rows and columns of `C` and
% `R`.
%
%
% __Options__
%
% * `ApplyTo=@all` [ cellstr | char | `@all` ] - List of variables to which
% the `Filter=` will be applied; `@all` means all variables.
%
% * `Contributions=false` [ `true` | `false` ] - If `true` the
% contributions of individual shocks to ACFs will be computed and stored in
% the 5th dimension of the `C` and `R` matrices.
%
% * `Filter=''` [ char ] - Linear filter that is applied to
% variables specified by the option `ApplyTo=`.
%
% * `NFreq=256` [ numeric ] - Number of equally spaced frequencies over
% which the filter in the option `Filter=` is numerically integrated.
%
% * `Order=0` [ numeric ] - Order up to which ACF will be computed.
%
% * `MatrixFormat='namedmat'` [ `'namedmat'` | `'plain'` ] - Return
% matrices `C` and `R` as either [`namedmat`](NamedMat) objects (matrices
% with named rows and columns) or plain numeric arrays.
%
% * `Select=@all` [ `@all` | char | cellstr ] - Return ACF for selected
% variables only; `@all` means all variables.
%
%
% __Description__
%
% `C` and `R` are both n-by-n-by-(p+1)-by-v matrices, where n is the
% number of measurement and transition variables (including auxiliary lags
% and leads in the state space vector), p is the order up to which the ACF
% is computed (controlled by the option `Order=`), and v is the number
% of parameter variants in the input model object, `M`.
% 
% If `Contributions=true`, the size of the two matrices is
% n-by-n-by-(p+1)-by-k-by-v, where k is the number of all shocks
% (measurement and transition) in the model.
%
%
% _ACF with Linear Filters_
%
% You can use the option `Filter=` to get the ACF for variables as though
% they were filtered through a linear filter. You can specify the filter in
% both the time domain (such as first-difference filter, or
% Hodrick-Prescott) and the frequncy domain (such as a band of certain
% frequncies or periodicities). The filter is a text string in which you
% can use the following references:
%
% * `'L'` for the lag operator, which will be replaced with
% `'exp(-1i*freq)'`;
% * `'per'` for the periodicity;
% * `'freq'` for the frequency.
% 
%
% __Example__
%
% A first-difference filter (i.e. computes the ACF for the first
% differences of the respective variables):
%
%     [C, R] = acf(m, 'Filter=', '1-L')
%
%
% __Example__
%
% The cyclical component of the Hodrick-Prescott filter with the smoothing
% parameter, \(\lambda\), set to 1,600. The formula for the filter follows
% from the classical Wiener-Kolmogorov signal extraction theory, 
%
% $$w(L) = \frac{\lambda}{\lambda + \frac{1}{ | (1-L)(1-L) | ^2}}$$
%
%     [C, R] = acf(m, 'Filter=', '1600/(1600 + 1/abs((1-L)^2)^2)')
%
%
% __Example__
%
% A band-pass filter with user-specified lower and upper bands. The
% band-pass filters can be defined either in frequencies or periodicities;
% the latter is usually more convenient. The following is a filter which
% retains periodicities between 4 and 40 periods (this would be between 1
% and 10 years in a quarterly model), 
%
%     [C, R] = acf(m, 'Filter=', 'per>=4 & per<=40')
%

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

persistent parser
if isempty(parser)
    parser = extend.InputParser('model.acf');
    parser.addRequired('Model', @(x) isa(x, 'model'));
    parser.addParameter('NFreq', 256, @(x) isnumeric(x) && isscalar(x) && x==round(x) && x>0);
    parser.addParameter({'Contributions', 'Contribution'}, false, @(x) isequal(x, true) || isequal(x, false));
    parser.addParameter('Order', 0, @(x) isnumeric(x) && isscalar(x) && x==round(x) && x>=0);
    parser.addParameter('MatrixFormat', 'NamedMat', @namedmat.validateMatrixFormat);
    parser.addParameter('Select', @all, @(x) (isequal(x, @all) || iscellstr(x) || ischar(x)) && ~isempty(x));
    parser.addParameter('ApplyTo', @all, @(x) isequal(x, @all) || iscellstr(x));
    parser.addParameter('Filter', '', @ischar);
    parser.addParameter('SystemProperty', false, @(x) isequal(x, false) || ((ischar(x) || isa(x, 'string') || iscellstr(x)) && ~isempty(x)));
    parser.addParameter('Progress', false, @(x) isequal(x, true) || isequal(x, false));
end
parser.parse(this, varargin{:});
opt = parser.Options;

isSelect = ~isequal(opt.Select, @all);
isNamedMat = strcmpi(opt.MatrixFormat, 'NamedMat');
isContributions = opt.Contributions;
isCorrelations = nargout>=2;

%--------------------------------------------------------------------------

[ny, nxi, ~, ~, ne] = sizeOfSolution(this.Vector);
nv = length(this);

if isContributions
    numContributions = ne;
else
    numContributions = 1;
end

% Pre-process filter options.
solutionVector = printSolutionVector(this, 'yx', @Behavior);
[isFilter, filter, freq, applyFilterTo] = freqdom.applyfilteropt(opt, [ ], solutionVector);

% _System Property_
systemProperty = createSystemPropertyObject( );
if ~isequal(opt.SystemProperty, false)
    systemProperty.OutputNames = opt.SystemProperty;
    varargout = { systemProperty };
    return
end

[CC, RR] = preallocate( );

indexNaNSolutions = reportNaNSolutions(this);

if opt.Progress
    progress = ProgressBar('IRIS model.acf progress');
end

for v = find(~indexNaNSolutions)
    update(systemProperty, this, v);
    [vthCC, vthRR] = covfun.wrapper(systemProperty);
    if isContributions
        CC(:, :, :, :, v) = vthCC;
        if isCorrelations
            RR(:, :, :, :, v) = vthRR;
        end
    else
        CC(:, :, :, v) = vthCC;
        if isCorrelations
            RR(:, :, :, v) = vthRR;
        end
    end
    if opt.Progress
        update(progress, v, ~indexNaNSolutions);
    end
end

% Select submatrices if requested
if isSelect
    [CC, pos] = namedmat.myselect(CC, solutionVector, solutionVector, opt.Select, opt.Select);
    pos = pos{1};
    solutionVector = solutionVector(pos);
    if isCorrelations
        RR = RR(pos, pos, :, :, :);
    end
end

% Convert double arrays to namedmat objects if requested.
if isNamedMat
    CC = namedmat(CC, solutionVector, solutionVector);
    if isCorrelations
        RR = namedmat(RR, solutionVector, solutionVector);
    end
end

varargout = cell(1, 3);
varargout{1} = CC;
varargout{2} = RR;
varargout{3} = solutionVector;

return


    function systemProperty = createSystemPropertyObject( )
        systemProperty = SystemProperty(this);
        systemProperty.Function = @covfun.wrapper;
        systemProperty.MaxNumOutputs = 2;
        systemProperty.NamedReferences = {solutionVector, solutionVector};
        systemProperty.Specifics = struct( );
        systemProperty.Specifics.MaxOrder = opt.Order;
        systemProperty.Specifics.IsContributions = isContributions;
        systemProperty.Specifics.IsCorrelations = isCorrelations;
        systemProperty.Specifics.NumContributions = numContributions;
        systemProperty.Specifics.IsFilter = isFilter;
        systemProperty.Specifics.Filter = filter;
        systemProperty.Specifics.ApplyFilterTo = applyFilterTo;
        systemProperty.Specifics.Frequencies = freq;
    end%


    function [CC, RR] = preallocate( )
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

