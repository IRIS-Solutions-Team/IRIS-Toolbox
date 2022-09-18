function [This,Y0,K0,Y1,G1] = uncmean(YBar,Mu,varargin)
% uncmean  Unconditional-mean dummy (or Sims' initial dummy) observations for BVARs.
%
% Syntax
% =======
%
%     O = BVAR.uncmean(YBar,Mu)
%
% Input arguments
% ================
%
% * `YBar` [ numeric ] - Vector of unconditional means imposed as priors.
%
% * `Mu` [ numeric ] - Weight on the dummy observations.
%
% Output arguments
% =================
%
% * `X` [ numeric ] - Array with prior dummy observations that can be used
% in the `'BVAR='` option of the [`VAR/estimate`](VAR/estimate) function.
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
pp.addRequired('YBar',@isnumeric);
pp.addRequired('Mu',isnumericscalar);
pp.parse(YBar,Mu);

if ~isempty(varargin) && nargout == 1
    exception.warning([
        "Deprecated"
        "This is an obsolete syntax to call BVAR.litterman;"
        "Use dummy.Litterman instead."
    ]);
end

%--------------------------------------------------------------------------

This = BVAR.DummyWrapper( );
This.name = 'uncmean';
This.y0 = @y0;
This.k0 = @k0;
This.y1 = @y1;
This.g1 = @g1;

if ~isempty(varargin) && nargout > 1
    [Y0,K0,Y1,G1] = BVAR.mydummymat(This,varargin{:});
end


% Nested functions...


%**************************************************************************

    
    function Y0 = y0(Ny,~,~,Nk)
        yBar = YBar(:);
        if length(yBar) == 1
            yBar = yBar(ones(Ny,1),1);
        end
        Y0 = yBar * Mu;
        if Nk ~= 1
            Y0 = Y0(:,ones(Nk,1));
        end
    end % y0( )


%**************************************************************************

    
    function K0 = k0(~,~,~,Nk)
        K0 = Mu*eye(Nk);
    end % k0( )


%**************************************************************************

    
    function Y1 = y1(Ny,P,~,Nk)
        yBar = YBar(:);
        if length(yBar) == 1
            yBar = yBar(ones(Ny,1),1);
        end        
        Y1 = repmat(yBar*Mu,P,1);
        if Nk ~= 1
            Y1 = Y1(:,ones(Nk,1));
        end
    end % y1( )


%**************************************************************************

    
    function G1 = g1(~,~,Ng,Nk)
        G1 = zeros(Ng,Nk);
    end % g1( )


end
