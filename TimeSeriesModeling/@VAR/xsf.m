function [S, D] = xsf(this, freq, varargin)
% xsf  Power spectrum and spectral density functions for VAR variables
%
% __Syntax__
%
%     [S, D] = xsf(VARModel, Freq, ...)
%
%
% __Input Arguments__
%
% * `VARModel` [ VAR ] - VAR object.
%
% * `Freq` [ numeric ] - Vector of frequencies at which the XSFs will be
% evaluated.
%
%
% __Output Arguments__
%
% * `S` [ numeric ] - Power spectrum matrices.
%
% * `D` [ numeric ] - Spectral density matrices.
%
%
% __Options__
%
% * `ApplyTo=@all` [ cellstr | char | `@all` ] - List of variables to which
% the `Filter=` will be applied; `@all` means all variables.
%
% * `Filter=''` [ char  | empty ] - Linear filter that is applied to
% variables specified by `ApplyTo=`.

% * `Progress=false` [ `true` | `false` ] - Display progress bar in the command
% window.
%
%
% __Description__
%
% The output matrices, `S` and `D`, are `N`-by-`N`-by-`K`, where `N` is the
% number of VAR variables and `K` is the number of frequencies (i.e. the
% length of the vector of frequencies `Freq`).
%
% The k-th page is the `S` matrix, i.e. `S(:, :, k)`, is the cross-spectrum
% matrix for the VAR variables at the k-th frequency. Similarly, the `k`-th
% page in `D`, i.e. `D(:, :, k)`, is the cross-density matrix.
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 IRIS Solutions Team

persistent inputParser
if isempty(inputParser)
    inputParser = extend.InputParser('VAR.xsf');
    inputParser.addRequired('VARModel', @(x) isa(x, 'VAR'));
    inputParser.addRequired('Freq', @isnumeric);
    inputParser.addParameter('ApplyTo', @all, @(x) isnumeric(x) || islogical(x) || isequal(x, @all) || iscellstr(x));
    inputParser.addParameter('Filter', '', @(x) ischar(x) || (isa(x, 'string') && isscalar(x)));
    inputParser.addParameter('Progress', false, @(x) isequal(x, true) || isequal(x, false));
end
inputParser.parse(this, freq, varargin{:});
opt = inputParser.Options;

%--------------------------------------------------------------------------

ny = size(this.A, 1);
nv = size(this.A, 3);
numFreq = numel(freq);

% Pre-process filter options.
[~, filter, ~, applyTo] = freqdom.applyfilteropt(opt, freq, this.EndogenousNames);

progress = [ ];
if opt.Progress
    progress = ProgressBar('[IrisToolbox] @VAR/xsf Progress');
end

S = nan(ny, ny, numFreq, nv);
for v = 1 : nv
    % Compute power spectrum function.
    S(:, :, :, v) = freqdom.xsfvar( ...
        this.A(:, :, v), this.Omega(:, :, v), freq, filter, applyTo);
    if ~isempty(progress)
        update(progress, v/nv);
    end
end
S = S / (2*pi);

if nargout>1
    % Convert power spectrum to spectral density.
    C = acf(this);
    D = freqdom.psf2sdf(S, C);
end

end
