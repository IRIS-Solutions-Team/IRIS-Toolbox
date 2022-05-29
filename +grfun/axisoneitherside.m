function ax = axisoneitherside(varargin)
% axisoneitherside  Show x-axis and/or y-axis on either side of a graph.
%
% Syntax
% =======
%
%     aa = grfun.axisoneitherside( )
%     aa = grfun.axisoneitherside(aa)
%     aa = grfun.axisoneitherside(spec)
%     aa = grfun.axisoneitherside(aa, spec)
%
% Input Arguments
% ================
%
% * `aa` [ numeric ] - Handle to the axes that will be changed.
%
% * `spec` [ 'x' | 'y' | 'xy' ] - Specification which axis or axes to show
% on either side of the graph.
%
% Output arguments
% =================
%
% * `aa` [ numeric ] - Handle to the axes changed.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

if ~isempty(varargin) && isnumeric(varargin{1})
   ax = varargin{1};
   varargin(1) = [ ];
else   
   ax = gca( );
end
if ~isempty(varargin)
   opt = lower(strtrim(varargin{1}));
   varargin(1) = [ ]; %#ok<NASGU>
else
   opt = 'xy';
end
nax = numel(ax);
if nax > 1
   ax2 = nan([2, nax]);
   for i = 1 : numel(ax)
      ax2(:, i) = yaxisboth(ax(i), opt);
   end
   ax = ax2;
   return
end

isXAxis = ~isempty(strfind(opt, 'x'));
isYAxis = ~isempty(strfind(opt, 'y'));

%--------------------------------------------------------------------------

ax2 = getappdata(ax, 'IRIS_AXIS_ON_EITHER_SIDE');
if isempty(ax2)
   keepTheOther = false;
   pa = get(ax, 'Parent');
   ax2 = copyobj(ax, pa);
   % Swap the two axes in the list of children to make sure the one with
   % the data is sits on top.
   ch = get(pa, 'Children');
   index1 = find(ch==ax);
   index2 = find(ch==ax2);
   [ch(index1), ch(index2)] = deal(ch(index2), ch(index1));
   set(pa, 'Children', ch);
   setappdata(ax, 'IRIS_AXIS_ON_EITHER_SIDE', ax2);
else
   keepTheOther = true;
end

cla(ax2);
set(ax2, 'XGrid', 'Off', 'YGrid', 'Off');
pn = {'*TickLabel', '*TickLabelMode', '*Tick', '*TickMode'};
pnx = strrep(pn, '*', 'x');
pny = strrep(pn, '*', 'y');
pvoff = {'', 'Manual', [ ], 'Manual'};
if isXAxis
   set(ax2, pnx, get(ax, pnx));
   set(ax2, 'XAxisLocation', 'Top');
elseif ~keepTheOther
   set(ax2, pnx, pvoff);
end
if isYAxis
   set(ax2, pny, get(ax, pny));
   set(ax2, 'YAxisLocation', 'Right');
elseif ~keepTheOther
   set(ax2, pny, pvoff);
end

ax = [ax;ax2];
linkaxes(ax, opt);

end
