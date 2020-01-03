function Lims = objbounds(This)
% objbounds  [Not a public function] Implementation of objbounds function
% missing in Octave.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2020 IRIS Solutions Team.

%--------------------------------------------------------------------------

try
    Lims = objbounds(This);
catch
    xLim = nan(1,2);
    yLim = nan(1,2);
    
    types = get(This,'type');
    
    if ischar(types)
        types = {types};
    end
    
    tags = get(This,'tag');
    
    if ischar(tags)
        tags = {tags};
    end
    
    [This,types] = xxReplaceAxesWithKids(This,types,tags);
    
    for ix = 1:numel(types)
        switch types{ix}
            case {'line', 'surface'}
                if strcmpi(get(This(ix),'xliminclude'),'on')
                    xData = get(This(ix), 'xData');
                else
                    xData = NaN;
                end
                if strcmpi(get(This(ix),'yliminclude'),'on')
                    yData = get(This(ix), 'yData');
                else
                    yData = NaN;
                end
            case 'patch'
                xyData = get(This(ix), 'vertices');
                fcs = get(This(ix), 'faces');
                xyData = xyData(fcs(isfinite(fcs)),:);
                if strcmpi(get(This(ix),'xliminclude'),'on')
                    xData = xyData(:,1);
                else
                    xData = NaN;
                end
                if strcmpi(get(This(ix),'yliminclude'),'on')
                    yData = xyData(:,2);
                else
                    yData = NaN;
                end
            otherwise
                xData = NaN;
                yData = NaN;
        end
        
        xLim = [min(xLim(1), min(xData)),max(xLim(2), max(xData))];
        yLim = [min(yLim(1), min(yData)),max(yLim(2), max(yData))];
    end
    
    Lims = [xLim, yLim, 0, 0];
end

end


% Subfunctions...


%**************************************************************************


function [This,Types] = xxReplaceAxesWithKids(This,Types,Tags)
axIx = strcmpi(Types,'axes') & ~strcmpi(Tags,'legend');
if all(~axIx)
    return
end
newKids = [ ];
newTypes = [ ];
newTags = [ ]; %#ok<NASGU>
for ix = find(axIx)
    allObj = findobj(This(ix));
    newKids = [newKids;allObj(2:end)]; %#ok<AGROW>
    newTypes = get(newKids,'type');
    newTags = get(newKids,'tag');
    [newKids,newTypes] = xxReplaceAxesWithKids(newKids,newTypes,newTags);
end
This = [This(~axIx);newKids];
Types = [Types(~axIx);newTypes];
end % xxReplaceAxesWithKids( )

