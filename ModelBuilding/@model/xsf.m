function [S, D, yxvec, freq] = xsf(this, freq, varargin)
% xsf  Power spectrum and spectral density of model variables.
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
% frequencies will be evenly spread between 0 and `pi`.
%
%
% __Output Arguments__
%
% * `S` [ namedmat | numeric ] - Power spectrum matrices.
%
% * `D` [ namedmat | numeric ] - Spectral density matrices.
%
% * `List` [ cellstr ] - List of variable in order of appearance in rows
% and columns of `S` and `D`.
%
% * `Freq` [ numeric ] - Vector of frequencies at which the XSFs has been
% evaluated.
%
%
% __Options__
%
% * `'ApplyTo='` [ cellstr | char | *`@all`* ] - List of variables to which
% the option `'filter='` will be applied; `@all` means all variables.
%
% * `'Filter='` [ char  | *empty* ] - Linear filter that is applied to
% variables specified by 'applyto'.
%
% * `'NFreq='` [ numeric | *`256`* ] - Number of equally spaced frequencies
% over which the 'filter' is numerically integrated.
%
% * `'MatrixFormat='` [ *`'namedmat'`* | `'plain'` ] - Return matrices `S`
% and `D` as either [`namedmat`](namedmat/Contents) objects (i.e.
% matrices with named rows and columns) or plain numeric arrays.
%
% * `'Progress='` [ `true` | *`false`* ] - Display progress bar on in the
% command window.
%
% * `'Select='` [ *`@all`* | char | cellstr ] - Return XSF for selected
% variables only; `@all` means all variables.
%
%
% __Description__
%
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

TYPE = @int8;

opt = passvalopt('model.xsf', varargin{:});

if isintscalar(freq)
    nFreq = freq;
    freq = linspace(0, pi, nFreq);
else
    freq = freq(:).';
    nFreq = length(freq);
end

isDensity = nargout > 1;
isSelect = ~isequal(opt.select, @all);
isNamedMat = strcmpi(opt.MatrixFormat, 'namedmat');

%--------------------------------------------------------------------------

[ny, nxi] = sizeOfSolution(this.Vector);
nv = length(this);

% Pre-process filter options.
yxvec = printSolutionVector(this, 'yx');
[~, filter, ~, applyTo] = freqdom.applyfilteropt(opt, freq, yxvec);

if opt.progress
    progress = ProgressBar('IRIS VAR.xsf progress');
end

S = nan(ny+nxi, ny+nxi, nFreq, nv);
indexOfSolutionsAvailable = issolved(this);
numOfUnitRoots = getNumOfUnitRoots(this.Variant);
for v = find(indexOfSolutionsAvailable)
    [T, R, ~, Z, H, ~, U, Omega] = sspaceMatrices(this, v, false);
    S(:, :, :, v) = freqdom.xsf( ...
        T, R, [ ], Z, H, [ ], U, Omega, numOfUnitRoots(v), ...
        freq, filter, applyTo ...
    );
    if opt.progress
        update(progress, v/nv);
    end
end
S = S / (2*pi);

% Report parameter variants with no solutions available.
assert( ...
    all(indexOfSolutionsAvailable), ...
    exception.Base('Model:SolutionNotAvailable', 'error'), ...
    exception.Base.alt2str(~indexOfSolutionsAvailable) ...
);

% Convert power spectrum to spectral density.
if isDensity
    C = acf(this);
    D = freqdom.psf2sdf(S, C);
end

% Select variables if requested.
if isSelect
    [S, pos] = namedmat.myselect(S, yxvec, yxvec, opt.select, opt.select);
    pos = pos{1};
    yxvec = yxvec(pos);
    if isDensity
        D = D(pos, pos, :, :, :);
    end
end

if true % ##### MOSW
    % Convert double arrays to namedmat objects if requested.
    if isNamedMat
        S = namedmat(S, yxvec, yxvec);
        try %#ok<TRYNC>
            D = namedmat(D, yxvec, yxvec);
        end
    end
else
    % Do nothing.
end

end
