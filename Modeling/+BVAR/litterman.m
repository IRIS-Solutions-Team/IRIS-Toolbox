function [This,Y0,K0,Y1,G1] = litterman(Rho,Mu,Lmb,varargin)
% litterman  Litterman's prior dummy observations for BVARs.
%
% Syntax
% =======
%
%     O = BVAR.litterman(Rho,Mu,Lmb)
%
% Input arguments
% ================
%
% * `Rho` [ numeric ] - White-noise priors (`Rho = 0`) or random-walk
% priors (`Rho = 1`), or something in between.
%
% * `Mu` [ numeric ] - Weight on dummy observations.
%
% * `Lmb` [ numeric ] - Exponential increase in weight depending on the
% lag; `Lmb = 0` means all lags are weighted equally.
%
% Output arguments
% =================
%
% * `O` [ bvarobj ] - BVAR object that can be passed into the
% [`VAR/estimate`](VAR/estimate) function.
%
% Description
% ============
%
% See the section explaining the [weights on prior dummies](BVAR/Contents),
% i.e. the input argument `Mu`.
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

pp = inputParser( );
pp.addRequired('Rho',@(x) isnumeric(x) && all(x >= 0 & x <= 1));
pp.addRequired('Mu',@(x) isnumeric(x) && all(x >= 0));
pp.addRequired('Lmb',@(x) isnumericscalar(x) && x >= 0);
pp.parse(Rho,Mu,Lmb);

if ~isempty(varargin) && nargout == 1
    utils.warning('BVAR', ...
        ['This is an obsolete syntax to call BVAR.litterman( ). ', ...
        'See documentation for valid syntax.']);
end

%--------------------------------------------------------------------------

Rho = Rho(:);
Mu = Mu(:);

This = BVAR.bvarobj( );
This.name = 'litterman';
This.y0 = @y0;
This.k0 = @k0;
This.y1 = @y1;
This.g1 = @g1;

if ~isempty(varargin) && nargout > 1
    [Y0,K0,Y1,G1] = BVAR.mydummymat(This,varargin{:});
end


% Nested functions...


%**************************************************************************
    
    
    function Y0 = y0(Ny,P,~,~)
        nd = Ny*P;
        muRho = Mu .* Rho;
        if length(muRho) == 1 && Ny > 1
            muRho = muRho(ones(1,Ny),1);
        end
        Y0 = [diag(muRho),zeros(Ny,nd-Ny)];
    end % y0( )


%**************************************************************************
    
    
    function K0 = k0(Ny,P,~,Nk)
        nd = Ny*P;
        K0 = zeros(Nk,nd);
    end % k0( )


%**************************************************************************
    
    
    function Y1 = y1(Ny,P,~,~)
        sgm = Mu;
        if length(sgm) == 1 && Ny > 1
            sgm = sgm(ones(1,Ny),1);
        end
        sgm = sgm(:,ones(1,P));
        if Lmb > 0
            lags = (1 : P).^Lmb;
            lags = lags(ones(1,Ny),:);
            sgm = sgm .* lags;
        end
        Y1 = diag(sgm(:));
    end % y1( )


%**************************************************************************
    
    
    function G1 = g1(Ny,P,Ng,~)
        nd = Ny*P;
        G1 = zeros(Ng,nd);
    end % g1( )


end
