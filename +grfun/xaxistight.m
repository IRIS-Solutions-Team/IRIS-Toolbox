function xaxistight(varargin)
% xaxistight  Make x-axis tight.
%
% Syntax
% =======
%
%     grfun.xaxistight(Ax)
%
% Input arguments
% ================
%
% * `Ax` [ numeric ] - Handles to axes objects whose horizontal axes will
% be made tight.
%
% Description
% ============
%
% Behaviour of `grfun.xaxistight` differs from the standard function `axis`
% in that it disregards `grfun.vline`, `grfun.zeroline` and
% `grfun.highlight` objects when determining the minimum and maximum on the
% vertical axis.
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

if ~isempty(varargin) && all(ishghandle(varargin{1}))
    Ax = varargin{1}(:).';
    varargin(1) = [ ]; %#ok<NASGU>
else
    Ax = gca( );
end

%--------------------------------------------------------------------------

for iAx = Ax
    
    ch = findobj(iAx,'-not','tag','highlight', ...
        '-and','-not','tag','vline', ...
        '-and','-not','tag','hline', ...
        '-and','-not','tag','zeroline');
    lim = objbounds(ch);
    if isempty(lim)
        xLim = get(iAx,'xLim');
    else
        xLim = lim(1:2);
    end
    
    if any(~isinf(xLim)) && xLim(1) < xLim(2)
        set(iAx,'xLim',xLim,'xLimMode','manual');
    end
    
end

end
