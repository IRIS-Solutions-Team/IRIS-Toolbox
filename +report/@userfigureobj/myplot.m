function This = myplot(This)
% myplot  [Not a public function] Plot userfigureobj object.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

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
    delete(figFile);
    This.handle = h;
end

end
