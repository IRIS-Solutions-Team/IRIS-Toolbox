function this = horzcat(this, varargin)
% horzcat  Combine two compatible VAR objects in one object with multiple parameterisations.
%
% __Syntax__
%
%     V = [V1, V2, ...]
%
%
% __Input arguments__
%
% * `V1`, `V2` [ VAR ] - Compatible VAR objects that will be combined.
%
%
% __Output arguments__
%
% * `V` [ VAR ] - Output VAR object that combines the input VAR
% objects as multiple parameterisations.
%
%
% __Description__
%
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

pp = inputParser( );
pp.addRequired('V1', @(x) isa(x, 'VAR'));
pp.addRequired('V2', @(x) all(cellfun(@(y) isa(y, 'VAR'), x)));
pp.parse(this, varargin);

%--------------------------------------------------------------------------

if nargin==1
   return
end

for i = 1 : numel(varargin)
    inx = size(this.A, 3) + (1 : size(varargin{1}.A, 3));
    this = subsalt(this, inx, varargin{i}, ':');
end

end
