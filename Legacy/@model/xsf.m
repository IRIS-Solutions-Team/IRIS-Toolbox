function varargout = xsf(this, freq, varargin)
% xsf  Power spectrum and spectral density for model variables
%
% ## Syntax ##
%
%     [S, D, List] = xsf(M, Freq, ...)
%     [S, D, List, Freq] = xsf(M, NFreq, ...)
%
%
% ## Input Arguments ##
%
% * `M` [ model ] - Model object.
%
% * `Freq` [ numeric ] - Vector of frequencies at which the XSFs will be
% evaluated.
%
% * `NFreq` [ numeric ] - Total number of requested frequencies; the
% frequencies will be evenly spread between 0 and \(\pi\).
%
%
% ## Output Arguments ##
%
% * `S` [ namedmat | numeric ] - Power spectrum matrices.
%
% * `D` [ namedmat | numeric ] - Spectral density matrices.
%
% * `List` [ cellstr ] - List of variables in order of their appearance in
% rows and columns of `SS` and `DD`.
%
% * `Freq` [ numeric ] - Vector of frequencies at which the XSFs has been
% evaluated.
%
%
% ## Options ##
%
% * `ApplyTo=@all` [ cellstr | char | `@all` ] - List of variables to which
% the option `Filter=` will be applied; `@all` means all variables.
%
% * `Filter=''` [ char ] - Linear filter that is applied to variables
% specified by 'applyto'.
%
% * `MatrixFormat='NamedMat'` [ `'NamedMat'` | `'Plain'` ] - Return
% matrices `SS` and `DD` as either [`namedmat`](namedmat/Contents) objects
% (i.e.  matrices with named rows and columns) or plain numeric arrays.
%
% * `Progress=false` [ `true` | `false` ] - Display progress bar on in
% the command window.
%
% * `Select=@all` [ cellstr | char | `@all` ] - Return XSF for selected
% variables only; `@all` means all variables.
%
%
% ## Description ##
%
%
% ## Example ##
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

persistent parser
if isempty(parser)
    parser = extend.InputParser('model.xsf');
    parser.addRequired('Model', @(x) isa(x, 'model'));
    parser.addRequired('Freq', @isnumeric);
    parser.addParameter('MatrixFormat', 'NamedMat', @validate.matrixFormat);
    parser.addParameter('Select', @all, @(x) (isequal(x, @all) || iscellstr(x) || ischar(x) || isstring(x)) && ~isempty(x));
    parser.addParameter('ApplyTo', @all, @(x) isequal(x, @all) || iscellstr(x) || isstring(x));
    parser.addParameter('Filter', '', @ischar);
    parser.addParameter('SystemProperty', false, @(x) isequal(x, false) || ((ischar(x) || isa(x, 'string') || iscellstr(x)) && ~isempty(x)));
    parser.addParameter('Progress', false, @(x) isequal(x, true) || isequal(x, false));
end
parse(parser, this, freq, varargin{:});
opt = parser.Options;

if isscalar(freq) && freq==round(freq) && freq>=0
    numOfFreq = freq;
    freq = linspace(0, pi, numOfFreq);
else
    freq = freq(:).';
    numOfFreq = numel(freq);
end

isDensity = nargout>=2;
isSelect = ~isequal(opt.Select, @all);
isNamedMat = strcmpi(opt.MatrixFormat, 'NamedMat');

%--------------------------------------------------------------------------

[ny, nxi] = sizeSolution(this.Vector);
nv = length(this);

solutionVector = printSolutionVector(this, 'yx', @Behavior);
[isFilter, filter, ~, applyFilterTo] = freqdom.applyfilteropt(opt, freq, solutionVector);

% Set up SystemProperty
systemProperty = hereSetupSystemProperty( );
if ~isequal(opt.SystemProperty, false)
    varargout = { systemProperty };
    return
end

[SS, DD] = herePreallocateOutputArrays( );

numOfUnitRoots = getNumOfUnitRoots(this.Variant);

if opt.Progress
    progress = ProgressBar('[IrisToolbox] @Model/xsf Progress');
end


% /////////////////////////////////////////////////////////////////////////
inxNaSolutions = reportNaNSolutions(this);
for v = find(~inxNaSolutions)
    update(systemProperty, this, v);
    freqdom.wrapper(this, systemProperty, v);
    SS(:, :, :, v) = systemProperty.Outputs{1};
    if isDensity
        DD(:, :, :, v) = systemProperty.Outputs{2};
    end
    if opt.Progress
        update(progress, v, ~inxNaSolutions);
    end
end
% /////////////////////////////////////////////////////////////////////////


% Select variables if requested
if isSelect
    [SS, pos] = namedmat.myselect(SS, solutionVector, solutionVector, opt.Select, opt.Select);
    pos = pos{1};
    solutionVector = solutionVector(pos);
    if isDensity
        DD = DD(pos, pos, :, :, :);
    end
end

% Convert double arrays to namedmat objects if requested.
if isNamedMat
    SS = namedmat(SS, solutionVector, solutionVector);
    if isDensity
        DD = namedmat(DD, solutionVector, solutionVector);
    end
end

varargout = cell(1, nargout);
varargout{1} = SS;
varargout{2} = DD;
varargout{3} = solutionVector;
varargout{4} = freq;

return


    function systemProperty = hereSetupSystemProperty( )
        systemProperty = SystemProperty(this);
        systemProperty.Function = @freqdom.wrapper;
        systemProperty.MaxNumOfOutputs = 2;
        systemProperty.NamedReferences = {solutionVector, solutionVector};
        systemProperty.CallerData = struct( );
        systemProperty.CallerData.Frequencies = freq;
        systemProperty.CallerData.IsDensity = isDensity;
        systemProperty.CallerData.IsFilter = isFilter;
        systemProperty.CallerData.Filter = filter;
        systemProperty.CallerData.ApplyFilterTo = applyFilterTo;
        if isequal(opt.SystemProperty, false)
            if ~isDensity
                systemProperty.OutputNames = {'SS'};
            else
                systemProperty.OutputNames = {'SS', 'DD'};
            end
        else
            systemProperty.OutputNames = opt.SystemProperty;
        end
        preallocateOutputs(systemProperty);
    end%


    function [SS, DD] = herePreallocateOutputArrays( )
        SS = nan(ny+nxi, ny+nxi, numOfFreq, nv);
        DD = double.empty(0);
        if isDensity
            DD = nan(size(SS));
        end
    end%
end%

