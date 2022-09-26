function [W, list] = ifrf(this, freq, varargin)

pp = inputParser( );
pp.addRequired('Freq',@isnumeric);
pp.parse(freq);


defaults = {
    'MatrixFormat', 'namedmat', @validate.matrixFormat
    'select', @all, @(x) (isequal(x, @all) || iscellstr(x) || ischar(x)) && ~isempty(x)
};

opt = passvalopt(defaults, varargin{:});


isSelect = ~isequal(opt.select,@all);
isNamedMat = strcmpi(opt.MatrixFormat,'namedmat');

%--------------------------------------------------------------------------

freq = freq(:)';
nFreq = length(freq);
[ny, nxx, ~, ~, ne] = sizeSolution(this.Vector);
nAlt = length(this);
W = zeros(ny+nxx, ne, nFreq, nAlt);

if ne>0
    ixSolved = true(1, nAlt);
    for iAlt = 1 : nAlt
        [T,R,K,Z,H,D,Za,Omg] = getSolutionMatrices(this,iAlt,false);
        
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

% Convert output matrix to namedmat object if requested.
if isNamedMat
    W = namedmat(W,rowNames,colNames);
end

end
