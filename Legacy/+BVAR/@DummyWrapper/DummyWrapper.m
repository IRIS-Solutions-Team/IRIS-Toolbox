% DummyWrapper  [Not a public class] Bayesian VAR object for creating dummy observations
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

classdef DummyWrapper
    properties
        name = '';
        y0 = '';
        y1 = '';
        k0 = '';
        g1 = '';
    end

    methods
        function flag = isempty(this)
            flag = isempty(this.y0);
        end%

        function [lhs, rhs] = dummyobs(this, varargin)
            lhs = this.y0(varargin{:});
            rhs = [ ...
                this.k0(varargin{:}); ...
                this.y1(varargin{:}); ...
                this.g1(varargin{:}); ...
            ];
        end%
    end
end
