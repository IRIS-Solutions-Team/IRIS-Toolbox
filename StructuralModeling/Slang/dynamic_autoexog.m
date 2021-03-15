% !dynamic_autoexog  Definitions of variable-shock pairs to be autoexogenized-autoendogenized in dynamic simulations.
%
% Syntax
% =======
%
%     !dynamic_autoexog
%         VariableName := ShockName; VariableName := ShockName;
%         VariableName := ShockName;
%
%
% Description
% ============
%
% The section `!dynamic_autoexog` defines pairs of variables and shocks
% that can be used to simplify and automate the creation of dynamic
% simulation [plans](plan/Contents) by calling the function
% [`autoexogenize`](plan/autoexogenize).
%
% On the left-hand side of the definition must be a valid measurement or
% transition variable name. On the right-hand side must be a valid
% measurement or transition shock name.
%
%
% Example
% ========
%
%     !transition_variables
%         X, Y, Z
%     !transition_shocks
%         ex, ey, ez
%     !measurement_variables
%         X_obs, Y_obs, Z_obs
%
%     !dynamic_autoexog
%         X := ex;
%         Y_obs := ey;
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2020 IRIS Solutions Team.
