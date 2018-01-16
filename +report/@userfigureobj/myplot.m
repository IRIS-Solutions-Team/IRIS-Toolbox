function This = myplot(This)
% myplot  [Not a public function] Plot userfigureobj object.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

if This.options.visible
    visibleFlag = 'on';
else
    visibleFlag = 'off';
end

%--------------------------------------------------------------------------

This = myplot@report.basefigureobj(This);

% Re-create the figure whose handle was captured at the
% time the figure constructor was called.
if ~isempty(This.savefig)
    figFile = [tempname(pwd( )),'.fig'];
    fid = fopen(figFile,'w+');
    fwrite(fid,This.savefig);
    fclose(fid);
    h = hgload(figFile);
    set(h,'visible',visibleFlag);
    utils.delete(figFile);
    This.handle = h;
    if true % ##### MOSW
        % Matlab only
        %-------------
        % Do nothing.
    else
        % Octave only
        %-------------
        a = findobj(h, 'type', 'axes'); %#ok<UNRCH>
        if ~isempty(a)
            xLimMode = getappdata(h, 'IRIS_XLIM_MODE');
            yLimMode = getappdata(h, 'IRIS_YLIM_MODE');
            zLimMode = getappdata(h, 'IRIS_ZLIM_MODE');
            set(a, ...
                'xLimMode', xLimMode, ...
                'yLimMode', yLimMode, ...
                'zLimMode', zLimMode);
        end
    end
end

end
