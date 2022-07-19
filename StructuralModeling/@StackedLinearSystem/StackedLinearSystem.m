% StackedLinearSystem  Stacked-time unobserved components linear system
%
% $$ 
% \begin{gathered}
%     X = T \, X_0 + R V + k \\
%     Y = Z X + H W + d
% \end{gathered}
% $$
%

classdef StackedLinearSystem ...
    < LinearSystem

    methods
        varargout = stackedSmoother(varargin)
    end
end

