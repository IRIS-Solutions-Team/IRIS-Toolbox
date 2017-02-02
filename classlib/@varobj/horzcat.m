function This = horzcat(This,varargin)
% horzcat  Combine two compatible VAR objects in one object with multiple parameterisations.
%
% Syntax
% =======
%
%     V = [V1,V2,...]
%
% Input arguments
% ================
%
% * `V1`, `V2` [ VAR ] - Compatible VAR objects that will be combined.
%
% Output arguments
% =================
%
% * `V` [ VAR ] - Output VAR object that combines the input VAR
% objects as multiple parameterisations.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

pp = inputParser( );
pp.addRequired('V1',@isVAR);
pp.addRequired('V2',@(x) all(cellfun(@isVAR,x)));
pp.parse(This,varargin);

%--------------------------------------------------------------------------

if nargin == 1
   return
end

for i = 1 : numel(varargin)
    inx = size(This.A,3) + (1 : size(varargin{1}.A,3));
    This = subsalt(This,inx,varargin{i},':');
end

end
