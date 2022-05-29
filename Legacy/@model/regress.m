function [B,CovRes,R2] = regress(This,Lhs,Rhs,varargin)
% regress  Centred population regression for selected model variables.
%
% Syntax
% =======
%
%     [B,CovRes,R2] = regress(M,Lhs,Rhs,...)
%
% Input arguments
% ================
%
% * `M` [ model ] - Model on whose covariance matrices the popolation
% regression will be based.
%
% * `Lhs` [ char | cellstr ] - Lhs variables in the regression; each of the
% variables must be part of the state-space vector.
%
% * `Rhs` [ char | cellstr ] - Rhs variables in the regression; each of the
% variables must be part of the state-space vector, or must refer to a
% larger lag of a transition variable present in the state-space vector.
%
% Output arguments
% =================
%
% * `B` [ namedmat | numeric ] - Population regression coefficients.
%
% * `CovRes` [ namedmat | numeric ] - Covariance matrix of residuals from
% the population regression.
%
% * `R2` [ numeric ] - Coefficient of determination (R-squared).
%
% Options
% ========
%
% * `'MatrixFormat='` [ *`'namedmat'`* | `'plain'` ] - Return matrices `B`
% and `CovRes` as either [`namedmat`](namedmat/Contents) object (i.e.
% matrices with named rows and columns) or plain numeric arrays.
%
% Description
% ============
%
% Population regressions calculated by this function are always centred.
% This means the regressions are always calculated as if estimated on
% observations with their uncondional means (the steady-state levels)
% removed from them.
%
% The Lhs and Rhs variables that are log variables must include
% `log( )` explicitly in their names. For instance, if `X` is declared
% to be a log variable, then you must refer to `log(X)` or `log(X{-1})`.
%
% Example
% ========
%
%     [B,C] = regress('log(R)',{'log(R{-1})','log(dP)'});
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

defaults = {
    'MatrixFormat', 'namedmat', @validate.matrixFormat
    'acf', { }, @(x) iscell(x) && iscellstr(x(1:2:end))
};
    
opt = passvalopt(defaults, varargin{:});

if ischar(Lhs)
    Lhs = regexp(Lhs,'[\w\(\)\{\}\d+\-]+','match');
end

if ischar(Rhs)
    Rhs = regexp(Rhs,'[\w\(\)\{\}\d+\-]+','match');
end

isNamedMat = strcmpi(opt.MatrixFormat,'namedmat');

%--------------------------------------------------------------------------

% Remove blank spaces from user names.
Lhs = regexprep(Lhs(:).','\s+','');
Rhs = regexprep(Rhs(:).','\s+','');

nAlt = length(This);

% `lhspos` is a vector of positions in [ Vector.Solution{1:2} ];
[~,~,lhsPos] = myfindsspacepos(This,Lhs,'-error');
nLhs = length(lhsPos);

% `rhspos` is a vector of either positions in [ Vector.Solution{1:2} ] (when
% imag is zero) or the position of the max lag of that variables in
% [ Vector.Solution{1:2} ] with imag being the distance to the lag requested.
% For example, if `x` enters [ Vector.Solution{1:2} ] as `x{-3}` at maximum, and
% requested is x{-5}, `rhspos` is the position of `x{-3}` and imag is -2.
% The minimum imag also determines the order up to which ACF needs to be
% calculated.
[~,~,rhsPos] = myfindsspacepos(This,Rhs,'-error');
nRhs = length(rhsPos);

p = -min([imag(rhsPos),imag(lhsPos)]);
C = acf(This,opt.acf{:},'order',p,'MatrixFormat','plain');
nc = size(C,1);

% Convert `lhspos` and `rhspos` to positions in
% `[ Vector.Solution{1:2}, Vector.Solution{1:2}{-1}, ...]`.
lhsPos = real(lhsPos) - nc*imag(lhsPos);
rhsPos = real(rhsPos) - nc*imag(rhsPos);

B = nan(nLhs,nRhs,nAlt);
CovRes = nan(nLhs,nLhs,nAlt);
R2 = nan(nLhs,nAlt);
for ialt = 1 : nAlt
    row = reshape(C(:,:,:,ialt),[nc,nc*(p+1)]);
    % CC := [C0,C1,C2,...;C1.',C0,C1,...;C2.',C1.',C0,...;...].
    CC = row;
    for k = 1 : p
        row = [C(:,:,k+1).',row(:,1:end-nc)];
        CC = [CC;row]; %#ok<AGROW>
    end
    % Y = B*X + RES.
    % YY is the cov matrix of Lhs variables.
    % YX is the cov matrix of Lhs versus Rhs variables.
    % XX is the cov matrix of Rhs variables.
    YY = CC(lhsPos,lhsPos);
    YX = CC(lhsPos,rhsPos);
    XX = CC(rhsPos,rhsPos);
    [B(:,:,ialt),CovRes(:,:,ialt)] = covfun.popregress(YY,YX,XX);
    R2(:,ialt) = 1 - diag(CovRes(:,:,ialt))./diag(YY);
end

if isNamedMat
    B = namedmat(B,Lhs,Rhs);
    CovRes = namedmat(CovRes,Lhs,Lhs);
end

end
