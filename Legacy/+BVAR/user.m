function This = user(UserY0,UserK0,UserY1,UserG1)
% user  User-supplied prior dummy observations for BVARs.
%
% Syntax
% =======
%
%     O = BVAR.user(Y0,K0,Y1,G1)
%
% Input arguments
% ================
%
% * `Y0` [ numeric ] - Column-wise prior dummy observations on the LHS.
%
% * `K0` [ numeric ] - Column-wise prior dummy observations on the RHS
% constant.
%
% * `Y1` [ numeric ] - Column-wise prior dummy observations on the RHS
% lagged variables.
%
% * `G1` [ numeric ] - Column-wise prior dummy observations on the RHS
% coefficients on the co-integrating vector.
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

pp = inputParser( );
pp.addRequired('Y0',@(x) isnumeric(x) && ismatrix(x));
pp.addRequired('K1',@(x) isnumeric(x) && ismatrix(x) ...
    && size(x,2) == size(UserY0,2));
pp.addRequired('Y1',@(x) isnumeric(x) && ismatrix(x) ...
    && size(x,2) == size(UserY0,2));
pp.addRequired('G1',@(x) isnumeric(x) && ismatrix(x) ...
    && size(x,2) == size(UserY0,2));
pp.parse(UserY0,UserK0,UserY1,UserG1);

%--------------------------------------------------------------------------

This = BVAR.DummyWrapper( );
This.name = 'user';
This.y0 = @y0;
This.k0 = @k0;
This.y1 = @y1;
This.g1 = @g1;


% Nested functions...


%**************************************************************************
    
    
    function Y0 = y0(~,~,~,~)
        Y0 = UserY0;
    end % y0( )


%**************************************************************************
    
    
    function K0 = k0(~,~,~,~)
        K0 = UserK0;
    end % k0( )


%**************************************************************************
    
    
    function Y1 = y1(~,~,~,~)
        Y1 = UserY1;
    end % y1( )


%**************************************************************************
    
    
    function G1 = g1(~,~,~,~)
        G1 = UserG1;
    end % g1( )


end
