% !measurement_equations  Block of measurement equations.
%
% Syntax
% =======
%
%     !measurement_equations
%         Equation1;
%         Equation2;
%         Equation3;
%         ...
%
% Syntax with equation labels
% ============================
%
%     !measurement_equations
%         Equation1;
%         'Equation label' Equation2;
%         Equation3;
%         ...
%
% Description
% ============
%
% The `!measurement_equations` keyword starts a new block of measurement
% equations; the equations can stretch over multiple lines and must be
% separated by semi-colons. You can have as many equation blocks as you
% wish in any order in your model file: They all get combined together when
% you read the model file in.
% 
% You can add descriptive labels to the equations (in single or double
% quotes, preceding the equation); these will be stored in, and
% accessible from, the model object.
%
% Example
% ========
%
%     !measurement_equations
%         'Inflation observations' Infl = 40*(P/P{-1} - 1);


% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.
