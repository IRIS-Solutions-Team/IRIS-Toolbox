% !reporting_equations  Block of reporting equations.
%
% Syntax
% =======
%
%     !reporting_equations
%         LhsName1 = Expression1;
%         LhsName2 = Expression2;
%         LhsName3 = Expression3;
%         ...
%
%
% Syntax with equation labels
% ============================
%
%     !reporting_equations
%         LhsName1 = Expression1;
%         'Equation 2' LhsName2 = Expression2;
%         LhsName3 = Expression3;
%         ...
%
%
% Description
% ============
%
% The `!reporting_equations` keyword starts a new block of reporting
% equations; the equations can stretch over multiple lines and must be
% separated by semi-colons. You can have as many equation blocks as you
% wish in any order in your model file: They all get combined together when
% you read the model file in.
% 
% You can add descriptive labels to the equations (in single or double
% quotes, preceding the equation); these will be stored in, and
% accessible from, the model object.
%
% Although they can be included within a model file and are stored withing
% a model object, reporting equations are, strictly speaking, not part of
% the model. They are executed separately from the rest of the model, by
% calling the function [`reporting`](model/reporting).
%
%
% Example
% ========
%
%     !reporting_equations
%         'GDP Growth' g = 100*(Y/Y{-1} - 1);


% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2019 IRIS Solutions Team.
