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

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team


classdef UncMean < dummy.Base
    properties
        YBar (:, 1) double
        Mu (1, 1) double
    end


    methods
        function this = UncMean(yBar, mu)
            if nargin==0
                return
            end
            this.YBar = yBar;
            this.Mu = mu;
        end%


        function y0 = evalY(this, var)
            [numY, numK, ~, ~] = dummy.Base.getDimensions(var);
            y0 = this.YBar;
            if isscalar(y0) && numY>1
                y0 = repmat(y0, numY, 1);
            end
            y0 = repmat(y0 * this.Mu, 1, numK);
        end%


        function k = evalK(this, var)
            [~, numK, ~, ~] = dummy.Base.getDimensions(var);
            k = this.Mu * eye(numK);
        end%


        function y1 = evalZ(this, var)
            [numY, numK, ~, order] = dummy.Base.getDimensions(var);
            y1 = this.YBar;
            if isscalar(y1) && numY>1
                y1 = repmat(y1, numY, 1);
            end
            y1 = repmat(y1 * this.Mu, order, 1);
            y1 = repmat(y1, 1, numK);
        end%


        function x = evalX(this, var)
            [~, numK, numX, ~] = dummy.Base.getDimensions(var);
            x = zeros(numX, numK);
        end%
    end
end

