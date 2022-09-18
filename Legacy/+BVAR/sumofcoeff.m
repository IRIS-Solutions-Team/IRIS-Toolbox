function [This,Y0,K0,Y1,G1] = sumofcoeff(Mu,varargin)
% sumofcoeff  Doan et al sum-of-coefficient prior dummy observations for BVARs.
%
% Syntax
% =======
%
%     O = BVAR.sumofcoeff(Mu)
%
% Input arguments
% ================
%
% * `Mu` [ numeric ] - Weight on the dummy observations.
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
% See [the section explaining the weights on prior dummies](BVAR/Contents),
% i.e. the input argument `Mu`.
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

isnumericscalar = @(x) isnumeric(x) && isscalar(x);
pp = inputParser( );
pp.addRequired('Mu',isnumericscalar);
pp.parse(Mu);

if ~isempty(varargin) && nargout==1
    exception.warning([
        "Deprecated"
        "This is an obsolete syntax to call BVAR.sumofcoeff;"
        "Use dummy.SumCoeff instead."
    ]);
end

%--------------------------------------------------------------------------

This = BVAR.DummyWrapper( );
This.name = 'sumofcoeff';
This.y0 = @y0;
This.k0 = @k0;
This.y1 = @y1;
This.g1 = @g1;

if ~isempty(varargin) && nargout > 1
    [Y0,K0,Y1,G1] = BVAR.mydummymat(This,varargin{:});
end


% Nested functions...


%**************************************************************************

    
    function Y0 = y0(Ny,~,~,~)
        Y0 = eye(Ny)*Mu;
    end % y0( )


%**************************************************************************


    function K0 = k0(Ny,~,~,Nk)
        K0 = zeros(Nk,Ny);
    end % k0( )


%**************************************************************************
    

    function Y1 = y1(Ny,P,~,~)
        Y1 = repmat(Mu*eye(Ny),P,1);
    end % y1( )


%**************************************************************************

    
    function G1 = g1(~,~,Ng,~)
        G1 = zeros(Ng,Ny);
    end % g1( )


end
