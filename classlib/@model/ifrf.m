function [W, list] = ifrf(this, freq, varargin)
% ifrf  Frequency response function to shocks.
%
% Syntax
% =======
%
%     [W,List] = ifrf(M,Freq,...)
%
%
% Input arguments
% ================
%
% * `M` [ model ] - Model object for which the frequency response function
% will be computed.
%
% * `Freq` [ numeric ] - Vector of frequencies for which the response
% function will be computed.
%
%
% Output arguments
% =================
%
% * `W` [ namedmat | numeric ] - Array with frequency responses of
% transition variables (in rows) to shocks (in columns).
%
% * `List` [ cell ] - List of transition variables in rows of the `W`
% matrix, and list of shocks in columns of the `W` matrix.
%
%
% Options
% ========
%
% * `'matrixFmt='` [ *`'namedmat'`* | `'plain'` ] - Return matrix `W` as
% either a [`namedmat`](namedmat/Contents) object (i.e. matrix with named
% rows and columns) or a plain numeric array.
%
% * `'select='` [ *`@all`* | char | cellstr ] - Return IFRF for selected
% variables only; `@all` means all variables.
%
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

% Parse input arguments.
pp = inputParser( );
pp.addRequired('Freq',@isnumeric);
pp.parse(freq);

% Parse options.
opt = passvalopt('model.ifrf',varargin{:});

isSelect = ~isequal(opt.select,@all);
isNamedMat = strcmpi(opt.MatrixFmt,'namedmat');

%--------------------------------------------------------------------------

freq = freq(:)';
nFreq = length(freq);
[ny, nxx, ~, ~, ne] = sizeOfSolution(this.Vector);
nAlt = length(this);
W = zeros(ny+nxx, ne, nFreq, nAlt);

if ne>0
    ixSolved = true(1, nAlt);
    for iAlt = 1 : nAlt
        [T,R,K,Z,H,D,Za,Omg] = sspaceMatrices(this,iAlt,false);
        
        % Continue immediately if solution is not available.
        ixSolved(iAlt) = all(~isnan(T(:)));
        if ~ixSolved(iAlt)
            continue
        end
        
        % Call Freq Domain package.
        W(:,:,:,iAlt) = freqdom.ifrf(T,R,K,Z,H,D,Za,Omg,freq);
    end
end

% Report NaN solutions.
if ~all(ixSolved)
    utils.warning('model:ifrf', ...
        'Solution(s) not available %s.', ...
        exception.Base.alt2str(~ixSolved) );
end

if nargout <= 1 && ~isSelect && ~isNamedMat
    return
end

% Variables and shocks in rows and columns of `W`.
rowNames = printSolutionVector(this,'yx');
colNames = printSolutionVector(this,'e');
    
% Select variables if requested.
if isSelect
    [W,pos] = namedmat.myselect(W,rowNames,colNames,opt.select);
    rowNames = rowNames(pos{1});
    colNames = colNames(pos{2});
end
list = {rowNames,colNames};

if true % ##### MOSW
    % Convert output matrix to namedmat object if requested.
    if isNamedMat
        W = namedmat(W,rowNames,colNames);
    end
else
    % Do nothing.
end

end
