% !steady_autoexog  Definitions of variable-parameter pairs to be autoexogenized-autoendogenized in steady-state calculations.
%
% Syntax
% =======
%
%     !steady_autoexog
%         VariableName := ParameterName; VariableName := ParameterName;
%         VariableName := ParameterName;
%
%
% Description
% ============
%
% The section `!steady_autoexog` defines pairs of variables and parameters
% that can be used to simplify and automate the definition of exogenized
% variables and endogenized parameters in steady-state calculations, i.e.
% in calling the function [`sstate`](model/sstate).
%
% On the left-hand side of the definition must be a valid measurement or
% transition variable name. On the right-hand side must be a valid
% parameter name.
%
%
% Example
% ========
%
%     !transition_variables
%         X, Y, Z
%     !parameters
%         alpha, beta, gamma
%     !measurement_variables
%         X_obs, Y_obs, Z_obs
%
%     !dynamic_autoexog
%         X := alpha;
%         Y_obs := beta;
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.
