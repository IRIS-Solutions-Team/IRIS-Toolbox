% %{...%}  Block comments.
%
% Syntax
% =======
%
%     %{ Anything between
%     the opening block comment sign
%     and the closing block comment sign
%     is discarded %}
%
% Description
% ============
%
% Unlike in Matlab, the opening and closing block comment signs do not need
% to stand alone on otherwise blank lines. You can even have block comments
% contained withing a single line.
%
% Example
% ========
%
%     !transition_equations
%         x = rho*x{-1} %{ this is a valid block comment %} + epsilon;

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.
