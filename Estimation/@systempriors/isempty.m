function Flag = isempty(this, varargin)
% isempty  True if system priors object is empty.
%
% __Syntax__
%
%     Flag = isempty(S)
%
%
% __Input Arguments__
%
% * `S` [ systempriors ] - System priors, 
% [`systempriors`](systempriors/Contents), object.
%
%
% __Output Arguments__
%
% * `Flag` [ true | false ] - True if the system priors object, `S`, is
% empty, false otherwise.
%
% __Description__
%
%
% __Example__

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

%--------------------------------------------------------------------------

if isempty(varargin)
    Flag = isempty(this.Eval);
else
    Flag = isempty(this.SystemFn.(lower(varargin{1})).page);
end

end
