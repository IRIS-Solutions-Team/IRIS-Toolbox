%{
% 
% # `acf` ^^(Model)^^
% 
% {== Autocovariance and autocorrelation function for model variables ==}
% 
% 
% ## Syntax 
% 
%     [C, R, list] = acf(model, ...)
% 
% 
% ## Input arguments 
% 
% __`model`__ [ Model ]
% > 
% > A solved model object for which the autocorrelation function will be
% > computed.
% > 
% 
% 
% ## Output arguments 
% 
% 
% __`C`__ [ NamedMat | numeric ]
% > 
% > Covariance matrices for measurement and transition variables.
% > 
% 
% __`R`__ [ NamedMat | numeric ]
% > 
% > Correlation matrices for measurement and transition variables.
% > 
% 
% __`list`__ [ string ]
% > 
% > List of variables in rows and columns of `C` and `R`.
% > 
% 
% ## Options 
% 
% __`ApplyTo=@all`__ [ string | `@all` ]
% > 
% > List of variables to which the `Filter=` will be applied; `@all` means
% > all variables.
% > 
% 
% __`Contributions=false`__ [ `true` | `false` ]
% > 
% > If `true` the contributions of individual shocks to ACFs will be computed
% > and stored in the 5th dimension of the `C` and `R` matrices.
% > 
% 
% __`Filter=""`__ [ string ]
% > 
% > Linear filter that is applied to variables specified by the option
% >`ApplyTo=`.
% > 
% 
% __`NFreq=256`__ [ numeric ]
% > 
% > Number of equally spaced frequencies over which the filter in the option
% > `filter=` is numerically integrated.
% > 
% 
% 
% __`Order=0`__ [ numeric ]
% > 
% > Order up to which ACF will be computed.
% > 
% 
% __`MatrixFormat="NamedMatrix"`__ [ `"NamedMatrix"` | `"plain"` ] 
% > 
% > Return matrices `C` and `R` as either
% > [NamedMatrix](../../DataManagement/@NamedMatrix/index.md) objects
% > (matrices with named rows and columns) or plain numeric arrays.
% > 
% 
% __`Select=@all`__ [ `@all` | string ]
% > 
% > Return ACF for selected variables only; `@all` means all variables.
% > 
% 
% ## Description 
% 
% The output matrices, `C` and `R`, are both n-by-n-by-(p+1)-by-v matrices,
% where n is the number of measurement and transition variables (including
% auxiliary lags and leads in the state space vector), p is the order up to
% which the ACF is computed (controlled by the option `Order=`), and v is
% the number of parameter variants in the input model object, `M`.
% 
% If `Contributions=true`, the size of the two matrices is
% n-by-n-by-(p+1)-by-k-by-v, where k is the number of all shocks
% (measurement and transition) in the model.
% 
% 
% ### Linear filters
% 
% 
% You can use the option `Filter=` to get the ACF for variables as though
% they were filtered through a linear filter. You can specify the filter in
% both the time domain (such as first-difference filter, or
% Hodrick-Prescott) and the frequncy domain (such as a band of certain
% frequncies or periodicities). The filter is a text string in which you
% can use the following references:
% 
% * `'L'` for the lag operator, which will be replaced with `'exp(-1i*freq)'`
% 
% * `'per'` for the periodicity
% 
% * `'freq'` for the frequency
% 
% 
% ## Example
% 
% 
% A first-difference filter (i.e. computes the ACF for the first
% differences of the respective variables):
% 
% ```matlab
% [C, R] = acf(m, 'Filter', '1-L')
% ```
% 
% 
% ## Example
% 
% 
% The cyclical component of the Hodrick-Prescott filter with the smoothing
% parameter, \(\lambda\), set to 1,600. The formula for the filter follows
% from the classical Wiener-Kolmogorov signal extraction theory, 
% 
% $$
% w(L) = \frac{\lambda}{\lambda + \frac{1}{ | (1-L)(1-L) | ^2}}
% $$
% 
% ```matlab
% [C, R] = acf(m, 'filter', '1600/(1600 + 1/abs((1-L)^2)^2)')
% ```
% 
% 
% ## Example
% 
% 
% A band-pass filter with user-specified lower and upper bands. The
% band-pass filters can be defined either in frequencies or periodicities;
% the latter is usually more convenient. The following is a filter which
% retains periodicities between 4 and 40 periods (this would be between 1
% and 10 years in a quarterly model), 
% 
% ```matlab
% [C, R] = acf(m, 'filter', 'per>=4 & per<=40')
% ```
% 
% 
%}
% --8<--


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

