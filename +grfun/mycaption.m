function H = mycaption(Ax, Loc, Cap, VPos, HPos)
% mycaption  Place text caption at the edge of an annotating object.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%--------------------------------------------------------------------------

% Horizontal position and alignment.
inside = length(Loc) > 1;
switch lower(HPos)
   case 'left'
      if inside
         hAlign = 'left';
      else
         hAlign = 'right';
      end
      x = Loc(1);
   case 'right'
      if inside
         hAlign = 'right';
      else
         hAlign = 'left';
      end
      x = Loc(end);
   otherwise
      hAlign = 'center';
      x = Loc(1) + (Loc(end) - Loc(1))/2;
end

% Vertical position and alignment.
ylim = get(Ax, 'yLim');
yspan = ylim(end) - ylim(1);
switch lower(VPos)
   case 'top'
      y = 0.98;
      vAlign = 'top';
   case 'bottom'
      y = 0.02;
      vAlign = 'bottom';
   case {'centre', 'center', 'middle'}
      y = 0.5;
      vAlign = 'middle';
   otherwise
      y = VPos;
      vAlign = 'middle';
end

H = text(x, ylim(1)+y*yspan, Cap, ...
   'parent', Ax, ...
   'color', [0, 0, 0], ...
   'verticalAlignment', vAlign, ...
   'horizontalAlignment', hAlign);

end
