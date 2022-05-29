function h = mychkforpeers(hAx)
% mychkforpeers  Check for plotyy peers and return the background axes object.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%--------------------------------------------------------------------------

peer = getappdata(hAx, 'graphicsPlotyyPeer');

if isempty(peer) || ~all(strcmpi(get(hAx, 'color'), 'none'))
    h = hAx;
else
    h = peer;
end

end
