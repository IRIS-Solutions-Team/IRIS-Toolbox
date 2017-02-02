function Flag = isempty(This,varargin)
% isempty  True if system priors object is empty.
%
% Syntax
% =======
%
%     Flag = isempty(S)
%
% Input arguments
% ================
%
% * `S` [ systempriors ] - System priors,
% [`systempriors`](systempriors/Contents), object.
%
% Output arguments
% =================
%
% * `Flag` [ true | false ] - True if the system priors object, `S`, is
% empty, false otherwise.
%
% Description
% ============
%
% Example
% ========

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

if isempty(varargin)
    Flag = isempty(This.Eval);
else
    Flag = isempty(This.SystemFn.(lower(varargin{1})).page);
end

end