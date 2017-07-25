function [X, YXVec, dbStd] = fmse(this, time, varargin)
% fmse  Forecast mean square error matrices.
%
% Syntax
% =======
%
%     [F,List,D] = fmse(M,NPer,...)
%     [F,List,D] = fmse(M,Range,...)
%
% Input arguments
% ================
%
% * `M` [ model ] - Model object for which the forecast MSE matrices will
% be computed.
%
% * `NPer` [ numeric ] - Number of periods.
%
% * `Range` [ numeric | char ] - Date range.
%
% Output arguments
% =================
%
% * `F` [ namedmat | numeric ] - Forecast MSE matrices.
%
% * `List` [ cellstr ] - List of variables in rows and columns of `M`.
%
% * `D` [ dbase ] - Database with the std deviations of
% individual variables, i.e. the square roots of the diagonal elements of
% `F`.
%
% Options
% ========
%
% * `'matrixFmt='` [ *`'namedmat'`* | `'plain'` ] - Return matrix `F` as
% either a [`namedmat`](namedmat/Contents) object (i.e. matrix with named
% rows and columns) or a plain numeric array.
%
% * `'select='` [ *`@all`* | char | cellstr ] - Return FMSE for selected
% variables only; `@all` means all variables.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

TYPE = @int8;

pp = inputParser( );
pp.addRequired('M', @(x) isa(x, 'model'));
pp.addRequired('Time', @(x) isdatinp(x));
pp.parse(this, time);

opt = passvalopt('model.fmse', varargin{:});

% tell whether time is nper or range
if ischar(time)
    time = textinp2dat(time);
elseif length(time)==1 && round(time)==time && time>0
    time = 1 : time;
end
Range = time(1) : time(end);
nPer = length(Range);

isSelect = ~isequal(opt.select,@all);
isNamedMat = strcmpi(opt.MatrixFmt,'namedmat');

%--------------------------------------------------------------------------

ixp = this.Quantity.Type==TYPE(4);
[ny, nxx] = sizeOfSolution(this.Vector);
nAlt = length(this);
X = zeros(ny+nxx, ny+nxx, nPer, nAlt);

ixSolved = true(1,nAlt);
for iAlt = 1 : nAlt
    [T,R,K,Z,H,dbStd,U,Omg] = sspaceMatrices(this,iAlt,false);
    
    % Continue immediately if solution is not available.
    ixSolved(iAlt) = all(~isnan(T(:)));
    if ~ixSolved(iAlt)
        continue
    end
    
    X(:,:,:,iAlt) = timedom.fmse(T,R,K,Z,H,dbStd,U,Omg,nPer);
end

% Report NaN solutions.
if ~all(ixSolved)
    utils.warning('model:fmse', ...
        'Solution(s) not available %s.', ...
        exception.Base.alt2str(~ixSolved) );
end

% Database of std deviations.
if nargout > 2
    % Select only contemporaneous variables.
    id = [this.Vector.Solution{1:2}];
    dbStd = struct( );
    for i = find(imag(id)==0)
        name = this.Quantity.Name{id(i)};
        dbStd.(name) = Series( ...
            Range, ...
            sqrt( permute(X(i, i, :, :), [3, 4, 1, 2]) ) ...
            );
    end
    for j = find(ixp)
        x = model.Variant.getQuantity(this.Variant, j, ':');
        dbStd.(this.Quantity.Name{j}) = permute(x, [1, 3, 2]);
    end
end

if nargout <= 1 && ~isSelect && ~isNamedMat
    return
end

YXVec = printSolutionVector(this,'yx');

% Select variables if requested.
if isSelect
    [X, pos] = namedmat.myselect(X,YXVec,YXVec,opt.select);
    pos = pos{1};
    YXVec = YXVec(pos);
end

if true % ##### MOSW
    % Convert output matrix to namedmat object if requested.
    if isNamedMat
        X = namedmat(X,YXVec,YXVec);
    end
else
    % Do nothing.
end

end
