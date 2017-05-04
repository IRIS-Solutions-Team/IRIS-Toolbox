function [S, D, yxvec, freq] = xsf(this, freq, varargin)
% xsf  Power spectrum and spectral density of model variables.
%
% Syntax
% =======
%
%     [S,D,List] = xsf(M,Freq,...)
%     [S,D,List,Freq] = xsf(M,NFreq,...)
%
%
% Input arguments
% ================
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
% Output arguments
% =================
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
% Options
% ========
%
% * `'applyTo='` [ cellstr | char | *`@all`* ] - List of variables to which
% the option `'filter='` will be applied; `@all` means all variables.
%
% * `'filter='` [ char  | *empty* ] - Linear filter that is applied to
% variables specified by 'applyto'.
%
% * `'nFreq='` [ numeric | *`256`* ] - Number of equally spaced frequencies
% over which the 'filter' is numerically integrated.
%
% * `'matrixFmt='` [ *`'namedmat'`* | `'plain'` ] - Return matrices `S`
% and `D` as either [`namedmat`](namedmat/Contents) objects (i.e.
% matrices with named rows and columns) or plain numeric arrays.
%
% * `'progress='` [ `true` | *`false`* ] - Display progress bar on in the
% command window.
%
% * `'select='` [ *`@all`* | char | cellstr ] - Return XSF for selected
% variables only; `@all` means all variables.
%
%
% Description
% ============
%
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

TYPE = @int8;

opt = passvalopt('model.xsf',varargin{:});

if isintscalar(freq)
    nFreq = freq;
    freq = linspace(0,pi,nFreq);
else
    freq = freq(:).';
    nFreq = length(freq);
end

isDensity = nargout > 1;
isSelect = ~isequal(opt.select,@all);
isNamedMat = strcmpi(opt.MatrixFmt,'namedmat');

%--------------------------------------------------------------------------

[ny, nxx] = sizeOfSolution(this.Vector);
nAlt = length(this);

% Pre-process filter options.
yxvec = printSolutionVector(this,'yx');
[~,filter,~,applyTo] = freqdom.applyfilteropt(opt,freq,yxvec);

if opt.progress
    progress = ProgressBar('IRIS VAR.xsf progress');
end

S = nan(ny+nxx,ny+nxx,nFreq,nAlt);
ixSolved = true(1,nAlt);
for iAlt = 1 : nAlt
    [T,R,~,Z,H,~,U,Omega] = sspaceMatrices(this,iAlt,false);
    
    % Continue immediately if solution is not available.
    ixSolved(iAlt) = all(~isnan(T(:)));
    if ~ixSolved(iAlt)
        continue
    end
    
    nUnit = sum(this.Variant{iAlt}.Stability==TYPE(1));
    S(:,:,:,iAlt) = freqdom.xsf(T,R,[ ],Z,H,[ ],U,Omega,nUnit, ...
        freq,filter,applyTo);
    if opt.progress
        update(progress,iAlt/nAlt);
    end
end
S = S / (2*pi);

% Report NaN solutions.
if ~all(ixSolved)
    utils.warning('model:xsf', ...
        'Solution(s) not available %s.', ...
        exception.Base.alt2str(~ixSolved) );
end

% Convert power spectrum to spectral density.
if isDensity
    C = acf(this);
    D = freqdom.psf2sdf(S,C);
end

% Select variables if requested.
if isSelect
    [S,pos] = namedmat.myselect(S,yxvec,yxvec,opt.select,opt.select);
    pos = pos{1};
    yxvec = yxvec(pos);
    if isDensity
        D = D(pos,pos,:,:,:);
    end
end

if true % ##### MOSW
    % Convert double arrays to namedmat objects if requested.
    if isNamedMat
        S = namedmat(S,yxvec,yxvec);
        try %#ok<TRYNC>
            D = namedmat(D,yxvec,yxvec);
        end
    end
else
    % Do nothing.
end

end
