% covmat  Covariance matrix prior dummy observations for BVARs.
%
% Syntax
% =======
%
%     O = BVAR.covmat(C,Rep)
%
% Input arguments
% ================
%
% * `C` [ numeric ] - Prior covariance matrix of residuals; if `C` is a
% vector it will be converted to a diagonal matrix.
%
% * `Rep` [ numeric ] - The number of times the dummy observations will
% be repeated.
%
% Output arguments
% =================
%
% * `O` [ DummyWrapper ] - BVAR object that can be passed into the
% [`VAR/estimate`](VAR/estimate) function.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

function [This,Y0,K0,Y1,G1] = covmat(C,Rep,varargin)

isintscalar = @(x) isnumeric(x) && isscalar(x) && round(x)==x;

% Parse input arguments.
pp = inputParser( );
pp.addRequired('Cov',@(x) isnumeric(x) && ismatrix(x));
pp.addRequired('Rep',@(x) isintscalar(x) && x > 0);
pp.parse(C,Rep);

%--------------------------------------------------------------------------

if isvector(C)
    C = diag(sqrt(C));
else
    C = chol(C).';
end

This = BVAR.DummyWrapper( );
This.name = 'covmat';
This.y0 = @y0;
This.k0 = @k0;
This.y1 = @y1;
This.g1 = @g1;

if ~isempty(varargin) && nargout > 1
    [Y0,K0,Y1,G1] = BVAR.mydummymat(This,varargin{:});
end


% Nested functions...


%**************************************************************************

    
    function Y0 = y0(~,~,~,~)
        Y0 = C;
        if Rep > 1
            Y0 = repmat(Y0,1,Rep);
        end
    end % y0( )


%**************************************************************************

    
    function K0 = k0(Ny,~,~,~)
        K0 = zeros(1,Ny);
        if Rep > 1
            K0 = repmat(K0,1,Rep);
        end
    end % k0( )


%**************************************************************************

    
    function Y1 = y1(Ny,P,~,~)
        Y1 = zeros(Ny*P,Ny);
        if Rep > 1
            Y1 = repmat(Y1,1,Rep);
        end
    end % y1( )


%**************************************************************************

    
    function G1 = g1(Ny,~,Ng,~)
        G1 = zeros(Ng,Ny);
        if Rep > 1
            G1 = repmat(G1,1,Rep);
        end
    end % g1( )


end
