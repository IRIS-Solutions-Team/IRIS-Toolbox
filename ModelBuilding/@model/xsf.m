function varargout = xsf(this, freq, varargin)
% xsf  Power spectrum and spectral density for model variables
%
% __Syntax__
%
%     [S, D, List] = xsf(M, Freq, ...)
%     [S, D, List, Freq] = xsf(M, NFreq, ...)
%
%
% __Input Arguments__
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
% __Output Arguments__
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
% __Options__
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
% __Description__
%
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

persistent inputParser
if isempty(inputParser)
    inputParser = extend.InputParser('model.xsf');
    inputParser.addRequired('Model', @(x) isa(x, 'model'));
    inputParser.addRequired('Freq', @isnumeric);
    inputParser.addParameter('MatrixFormat', 'NamedMat', @namedmat.validateMatrixFormat);
    inputParser.addParameter('Select', @all, @(x) (isequal(x, @all) || iscellstr(x) || ischar(x)) && ~isempty(x));
    inputParser.addParameter('ApplyTo', @all, @(x) isequal(x, @all) || iscellstr(x));
    inputParser.addParameter('Filter', '', @ischar);
    inputParser.addParameter('SystemProperty', false, @(x) isequal(x, false) || ((ischar(x) || isa(x, 'string') || iscellstr(x)) && ~isempty(x)));
    inputParser.addParameter('Progress', false, @(x) isequal(x, true) || isequal(x, false));
end
inputParser.parse(this, freq, varargin{:});
opt = inputParser.Options;

if isscalar(freq) && freq==round(freq) && freq>=0
    numFreq = freq;
    freq = linspace(0, pi, numFreq);
else
    freq = freq(:).';
    numFreq = numel(freq);
end

isDensity = nargout>=2;
isSelect = ~isequal(opt.Select, @all);
isNamedMat = strcmpi(opt.MatrixFormat, 'NamedMat');

%--------------------------------------------------------------------------

[ny, nxi] = sizeOfSolution(this.Vector);
nv = length(this);

solutionVector = printSolutionVector(this, 'yx', @Behavior);
[isFilter, filter, ~, applyFilterTo] = freqdom.applyfilteropt(opt, freq, solutionVector);

% _System Property_
systemProperty = createSystemPropertyObject( );
if ~isequal(opt.SystemProperty, false)
    systemProperty.OutputNames = opt.SystemProperty;
    varargout = { systemProperty };
    return
end

[SS, DD] = preallocate( );

numOfUnitRoots = getNumOfUnitRoots(this.Variant);

indexNaNSolutions = reportNaNSolutions(this);

if opt.Progress
    progress = ProgressBar('IRIS model.xsf progress');
end
for v = find(~indexNaNSolutions)
    update(systemProperty, this, v);
    [vthSS, vthDD] = freqdom.wrapper(systemProperty);
    SS(:, :, :, v) = vthSS;
    if isDensity
        DD(:, :, :, v) = vthDD;
    end
    if opt.Progress
        update(progress, v, ~indexNaNSolutions);
    end
end

% Select variables if requested.
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


    function systemProperty = createSystemPropertyObject( )
        systemProperty = SystemProperty(this);
        systemProperty.Function = @freqdom.wrapper;
        systemProperty.MaxNumOutputs = 2;
        systemProperty.NamedReferences = {solutionVector, solutionVector};
        systemProperty.Specifics = struct( );
        systemProperty.Specifics.Frequencies = freq;
        systemProperty.Specifics.IsDensity = isDensity;
        systemProperty.Specifics.IsFilter = isFilter;
        systemProperty.Specifics.Filter = filter;
        systemProperty.Specifics.ApplyFilterTo = applyFilterTo;
    end


    function [SS, DD] = preallocate( )
        SS = nan(ny+nxi, ny+nxi, numFreq, nv);
        DD = double.empty(0);
        if isDensity
            DD = nan(size(SS));
        end
    end
end
