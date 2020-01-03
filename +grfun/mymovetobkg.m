function mymovetobkg(Ax)
% mymovetobkg  Correct order of graphics objects.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2020 IRIS Solutions Team.

if isempty(Ax)
    return
end

nAx = length(Ax);
if nAx>1
    for i = 1 : nAx
        grfun.mymovetobkg(Ax(i));
    end
    return
end

%--------------------------------------------------------------------------

ch = get(Ax,'children');

highlightPos = [ ];
vLinePos = [ ];
hLinePos = [ ];
bandPos = [ ];
otherPos = [ ];
for i = 1 : length(ch)
    bkgLabel = getappdata(ch(i),'IRIS_BACKGROUND');
    if isequal(bkgLabel,'Highlight')
        highlightPos = [highlightPos,i]; %#ok<AGROW>
    elseif isequal(bkgLabel,'VLine')
        vLinePos = [vLinePos,i]; %#ok<AGROW>
    elseif isequal(bkgLabel,'HLine')
        hLinePos = [hLinePos,i]; %#ok<AGROW>
    elseif isequal(bkgLabel,'Band')
        bandPos = [bandPos,i]; %#ok<AGROW>
    else
        otherPos = [otherPos,i]; %#ok<AGROW>
    end
end

permutePos = [otherPos,bandPos,hLinePos,vLinePos,highlightPos];
set(Ax,'children',ch(permutePos));

end
