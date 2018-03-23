% !measurement_variables  List of measurement variables.
%
% Syntax
% =======
%
%     !measurement_variables
%         VariableName, VariableName, ...
%         ...
%
% Syntax with descriptors
% ========================
%
%     !measurement_variables
%         VariableName, VariableName, ...
%         'Description of the variable...' VariableName
%
% Syntax with steady-state values
% ================================
%
%     !measurement_variables
%         VariableName, VariableName, ...
%         VariableName = Value
%
% Description
% ============
% 
% The `!measurement_variables` keyword starts a new declaration block for
% measurement variables (i.e. observables); the names of the variables must
% be separated by commas, semi-colons, or line breaks. You can have as many
% declaration blocks as you wish in any order in your model file: They all
% get combined together when you read the model file in. Each variable must
% be declared (exactly once).
% 
% You can add descriptors to the variables (enclosed in single or double
% quotes, preceding the name of the variable); these will be stored in, and
% accessible from, the model object. You can also assign steady-state
% values to the variables straight in the model file (following an equal
% sign after the name of the variable); this is, though, rather rare and
% unnecessary practice because you can assign and change steady-state
% values more conveniently in the model object.
%
% For each individual variable in a non-linear model, you can also decide
% if it is to be linearised or log-linearised by listing its name in the
% [`!log_variables`](irislang/logvariables) section.
% 
% Example
% ========
% 
%     !measurement_variables
%         pie, 'Real output' Y
%         'Real exchange rate' Z = 1 + 1.05i;
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

