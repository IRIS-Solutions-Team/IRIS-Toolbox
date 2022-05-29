function C = printcaption(This,NCol,Just,Space)
% printcaption  [Not a public function] Typeset title and subtitle in mutlicolumn mode.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

try
    NCol; %#ok<*VUNUS>
catch %#ok<*CTCH>
    NCol = 1;
end

try
    Just;
catch
    Just = 'c';
end

try
    Space;
catch
    Space = '';
end

%--------------------------------------------------------------------------

C = '';
br = sprintf('\n');
title = This.title;
subTitle = This.subtitle;

if ~isempty(Space)
    Space = sprintf('[%gpt]',Space);
end
NCol = sprintf('%g',NCol);

if ~isempty(title)
    
	% Split title.
    C = [C,xxSplitTitle(This,title, ...
        NCol,Just,mytitletypeface(This), ...
        footnotemark(This))];
    
    % Split subtitle if not empty.
    if ~isempty(subTitle)
        C = [C,br, ...
            xxSplitTitle(This,subTitle, ...
            NCol,Just,mysubtitletypeface(This),'')];
    end
    
    % The title/subtitle string is returned with a `\\` but no linebreak;
    % add a requested vertical space now.
    C = [C,Space];
    
else
    C = [C,'\\[-2.8ex]'];
end

end


% Subfunctions...


%**************************************************************************
function C = xxSplitTitle(This,Title,NCol,Just,TypeFace,FootnoteMark)

br = sprintf('\n');
C = '';
while true
    [tok,last] = regexp(Title,'(.*?)(\{\\\\.*?\}|$)','tokens','end','once');
    text = interpret(This,tok{1});
    div = tok{2};
    if isempty(div)
        div = '\\';
    else
        div = div(2:end-1);
    end
    Title(1:last) = '';
    C = [C, ...
        '\multicolumn{',NCol,'}{',Just,'}', ...
        '{',TypeFace,' ',text,FootnoteMark,'}']; %#ok<AGROW>
    
    % Return the title/subtitle string with a `\\` or `\\[...]` but no
    % linebreak.
    C = [C,div]; %#ok<AGROW>
    if isempty(Title)
        break
    end
    C = [C,br]; %#ok<AGROW>
    
end % xxSplitTitle( )


end
