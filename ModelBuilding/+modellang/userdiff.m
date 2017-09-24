% !userdiff  List of user m-file functions that return user-supplied derivatives.
%
% Syntax
% =======
%
%     !userdiff
%         FUNCTION_NAME, FUNCTION_NAME,
%         FUNCTION_NAME
%
% Description
% ============
%
% You can use any functions or your own m-file functions (provided they are
% visible on the Matlab search path or in the current working directory) in
% model files. When computing the Taylor expansion of the model equations,
% IRIS uses symbolic/automatic differentiator for all elementary functions.
% Other functions are differentiated numerically.
%
% Instead of that, you can supply first derivatives (and also second
% derivatives in case one of a function occuring in a loss function,
% [`min`](modellang/min)) for you m-file functions use in the model file.
% The function must be designed to comply with certain rules, see [Matlab
% functions and user functions in model files](modellang/Contents), and in
% addition, must be also declared in the model file itself under the
% heading `!userdiff`.
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.
