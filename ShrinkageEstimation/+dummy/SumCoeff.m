% sumofcoeff  Doan et al sum-of-coefficient prior dummy observations for BVARs.
%
% Syntax
% =======
%
%     x = dummy.SumCoeff(mu)
%
%
% Input arguments
% ================
%
% * `mu` [ numeric ] - Weight on the dummy observations.
%
% Output arguments
% =================
%
% * `x` [ dummy.SumCoeff ] - Dummy object that can be passed into the
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


classdef SumCoeff < dummy.Base
    properties
        Mu = 0 % [0, Inf)
    end


    methods
        function this = SumCoeff(mu)
            if nargin==0
                return
            end
            this.Mu = mu;
        end%


        function Y = evalY(this, var)
            [numY, ~, ~, ~] = dummy.Base.getDimensions(var);
            Y = eye(numY) * this.Mu;
        end%


        function k = evalK(this, var)
            [numY, numK, ~, ~] = dummy.Base.getDimensions(var);
            k = zeros(numK, numY);
        end%


        function Z = evalZ(this, var)
            [numY, ~, ~, order] = dummy.Base.getDimensions(var);
            Z = repmat(this.Mu*eye(numY), order, 1);
        end%


        function X = evalX(this, var)
            [numY, ~, numX, ~] = dummy.Base.getDimensions(var);
            X = zeros(numX, numY);
        end%
    end
end

