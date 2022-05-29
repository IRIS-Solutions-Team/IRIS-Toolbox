% copy  Create a copy of a report object.
%
% Syntax
% =======
%
%     Q = copy(P)
%
% Input arguments
% ================
%
% * `P` [ report ] - Report object whose copy will be created.
%
% Output arguments
% =================
%
% * `Q` [ report ] - Copy of the input report object.
%
% Description
% ============
%
% Because `report` is a handle class object, a plain assignment
%
%     Q = P;
%
% creates a handle to the same copy of a report object. In other words,
% changes in `Q` will also change `P` and vice versa. To make a new,
% independent copy of an existing report object, you need to run
%
%     Q = copy(P);
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.
