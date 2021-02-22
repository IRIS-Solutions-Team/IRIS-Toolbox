% '...!!...'  Beginning of aliasing inside descriptions and labels.
%
% Syntax in descriptions of variables, shocks, and parameters
% ============================================================
%
%     'Description !! Alias' Name
%
% Syntax in equations labels
% ===========================
%
%     'Label !! Alias' Equation;
%
% Description
% ============
%
% When used in descriptions of variables, shocks, and parameters, or in
% equation labels, the double exclamation mark starts an alias (but the
% exlamation marks are not included in it). The alias can be used to
% specify, for example, a LaTeX code associated with the variable, shock,
% parameter, or equation. The aliases can be retrieved from the model code
% by using the appropriate query in the function [`model/get`](model/get).
%
% Example
% ========
%
%     !transition_variables
%         'Output gap !! $\hat y_t$` Y_GAP
%
% In the resulting model object, the description of the variables `Y_GAP`
% will be
%
%     Output gap
%
% while its alias will be
%
%     $\hat y_t$.
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2020 IRIS Solutions Team.
