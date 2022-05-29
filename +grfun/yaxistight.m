function yaxistight(handlesAxes)
% yaxistight  Make y-axis tight
%
% __Syntax__
%
%     grfun.yaxistight(Axes)
%
%
% __Input Arguments__
%
% * `Axes` [ numeric ] - Handles to axes objects whose vertical axes will
% be made tight.
%
%
% __Description__
%
% Calling `grfun.yaxistight( )` can be now directly replaced by setting the
% following axes property
%
%     set(h, 'YLimSpec', 'Tight')
%
% where `h` is the handle to the respective axes object.
%
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 IRIS Solutions Team

if nargin==0
    handlesAxes = visual.backend.getCurrentAxesIfExists( );
end

%--------------------------------------------------------------------------

if isempty(handlesAxes)
    return
end

set(handlesAxes, 'YLimSpec', 'Tight');

end%

