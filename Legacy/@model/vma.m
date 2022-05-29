function [phi, list] = vma(this, nPer, varargin)
% vma  Vector moving average representation of the model.
%
% Syntax
% =======
%
%     [Phi,List] = vma(M,P,...)
%
% Input arguments
% ================
%
% * `M` [ model ] - Model object for which the VMA representation will be
% computed.
%
% * `P` [ numeric ] - Order up to which the VMA will be evaluated.
%
% Output arguments
% =================
%
% * `Phi` [ namedmat | numeric ] - VMA matrices.
%
% * `List` [ cell ] - List of measurement and transition variables in
% the rows of the `Phi` matrix, and list of shocks in the columns of the
% `Phi` matrix.
%
% Option
% =======
%
% * `'MatrixFormat='` [ *`'namedmat'`* | `'plain'` ] - Return matrix `Phi`
% as either a [`namedmat`](namedmat/Contents) object (i.e. matrix with
% named rows and columns) or a plain numeric array.
%
% * `'select='` [ *`@all`* | char | cellstr ] - Return VMA for selected
% variables only; `@all` means all variables.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

defauls = {
    'MatrixFormat', 'namedmat', @validate.matrixFormat
    'select', @all, @(x) (isequal(x, @all) || iscellstr(x) || ischar(x)) && ~isempty(x)
};

opt = passvalopt(defauls, varargin{:});

isSelect = ~isequal(opt.select,@all);
isNamedMat = strcmpi(opt.MatrixFormat,'namedmat');

%--------------------------------------------------------------------------

[ny, nxx, ~, ~, ne] = sizeSolution(this.Vector);
nAlt = length(this);
phi = zeros(ny+nxx, ne, nPer+1, nAlt);
ixSolved = true(1, nAlt);

for iAlt = 1 : nAlt
   [T,R,K,Z,H,D,U,Omg] = getSolutionMatrices(this,iAlt,false);
    % Continue immediately if solution is not available.
    ixSolved(iAlt) = all(~isnan(T(:)));
    if ~ixSolved(iAlt)
        continue
    end
   phi(:,:,:,iAlt) = timedom.srf(T,R,K,Z,H,D,U,Omg,nPer,1);
end

% Remove pre-sample period.
phi(:,:,1,:) = [ ];

% Report NaN solutions.
if ~all(ixSolved)
    utils.warning('model:vma', ...
        'Solution(s) not available %s.', ...
        exception.Base.alt2str(~ixSolved) );
end

if nargout<=1 && ~isSelect && ~isNamedMat
    return
end

% List of variables in rows (measurement and transion) and columns (shocks)
% of matrix `Phi`.
rowNames = printSolutionVector(this,'yx');
colNames = printSolutionVector(this,'e');

% Select variables if requested.
if isSelect
    [phi,pos] = namedmat.myselect(phi,rowNames,colNames,opt.select);
    rowNames = rowNames(pos{1});
    colNames = colNames(pos{2});    
end
list = {rowNames,colNames};

% Convert output matrix to namedmat object if requested.
if isNamedMat
    phi = namedmat(phi,rowNames,colNames);
end

end
