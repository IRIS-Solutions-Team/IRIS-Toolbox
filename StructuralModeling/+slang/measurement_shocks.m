% !measurement_shocks  List of measurement shocks.
%
% Syntax
% =======
%
%     !measurement_shocks
%         ShockName, ShockName, ...
%         ...
%
% Syntax with descriptors
% ========================
%
%     !measurement_shocks
%         ShockName, ShockName, ...
%         'Description of the shock...' ShockName
%
% Description
% ============
% 
% The `!measurement_shocks` keyword starts a new declaration block for
% measurement shocks (i.e. shocks or errors to measurement equation); the
% names of the shocks must be separated by commas, semi-colons, or line
% breaks. You can have as many declaration blocks as you wish in any order
% in your model file: They all get combined together when you read the
% model file in. Each shock must be declared (exactly once).
% 
% You can add descriptors to the shocks (enclosed in single or double
% quotes, preceding the name of the shock); these will be stored in, and
% accessible from, the model object.
% 
% Example
% ========
% 
%     !measurement_shocks
%         u1, 'Output measurement error' u2
%         u3
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2020 IRIS Solutions Team.
