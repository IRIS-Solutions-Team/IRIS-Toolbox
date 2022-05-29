function [answ, flag] = implementGet(this, query, varargin)
% implementGet  Implement get method for DFM objects.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%--------------------------------------------------------------------------

[answ, flag] = implementGet@BaseVAR(this, query, varargin{:});
if flag
    return
end

answ = [ ];
flag = true;

nx = size(this.C, 2);
p = size(this.A, 2)/nx;
nAlt = size(this.C, 3);

switch query
    case 'a'
        if all(size(this.A)==0)
            answ = [ ];
        else
            answ = polyn.var2polyn(this.A);
        end
        
    case 'a*'
        answ = reshape(this.A, [nx, nx, p, nAlt]);
        
    case 'b'
        answ = this.B;
        
    case 'c'
        answ = this.C;
        
    case 'omega'
        answ = this.Omega;
        
    case 'sigma'
        answ = this.Sigma;
        
    case 'var'
        answ = VAR(this);
        
    case {'singval', 'sing', 'singvalues'}
        answ = this.SingValues;
        
    case {'ny'}
        answ = size(this.C, 1);
        
    case {'nx', 'nfactor', 'nfactors'}
        answ = size(this.A, 1);
        
    case {'ne'}
        answ = size(this.Omega, 2);
        
    case 'nu'
        answ = size(this.Sigma, 2);
        
    case 'mean'
        answ = this.Mean;
        
    case 'std'
        answ = this.Std;
        
    otherwise
        flag = false;
end

end
