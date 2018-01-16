function d = addparam(this, d)
% addparam  Add VAR parameters to databank. 
%
% __Syntax__
%
%     D = addparam(V, D)
%
%
% __Input Arguments__
%
% * `V` [ VAR ] - VAR object whose parameter matrices will be added to
% databank (struct) `D`.
%
% * `D` [ struct ] - Databank to which the model parameters will be added.
%
%
% __Output Arguments__
%
% * `D [ struct ] - Databank with the VAR parameter matrices added.
%
%
% __Description__
%
% The newly created databank entries are named `A_` (transition matrix), 
% `K_` (constant terms), `J_` (coefficient matrix in front of exogenous
% inputs), `B_` (matrix of instantaneous whock effects), and `Cov_`
% (covariance matrix of shocks). Be aware that all existing databank
% entries in `D` named `A_`, `K_`, `B_`, or `Omg_` will be overwritten.
%
%
% __Example__
%
%     D = struct( );
%     D = addparam(V, D);
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

if nargin<2
    d = struct( );
end

%--------------------------------------------------------------------------

d.A_ = this.A;
d.B_ = mybmatrix(this);
d.K_ = this.K;
d.J_ = this.J;
d.Cov_ = mycovmatrix(this);

end
