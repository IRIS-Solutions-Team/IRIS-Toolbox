function C = speclatexcode(This)
% speclatexcode  [Not a public function] ...
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%--------------------------------------------------------------------------

br = sprintf('\n');
C = '';

nChild = length(This.children);
if nChild == 0
    return
end

nCol = min(This.ncol,nChild);
oneCol = ...
    ['l@{\hspace*{',sprintf('%gem',This.options.hspace),'}}'];
colSpec = ...
    ['{@{\hspace*{-3pt}}',repmat(oneCol,1,nCol-1),'l}'];
C = [C,'\begin{tabular}[t]',colSpec];
ch = This.children;

while ~isempty(ch)
    n = min(nCol,length(ch));
    % All objects in this row.
    objs = ch(1:n);
    ch(1:n) = [ ];
    
    [This,objs] = xxShareCaption(This,objs);
    
    if ~isempty(This.title)
        C = [C, br, ...
            printcaption(This,n,'c',7)]; %#ok<AGROW>
    end
    
    for i = 1 : n
        c1 = latexcode(objs{i});
        C = [C, br, c1]; %#ok<AGROW>
        if i < n
            C = [C, br, '&']; %#ok<AGROW>
        end
    end
    if ~isempty(ch)
        C = [C, br, '\\ \\ \\']; %#ok<AGROW>
    end
end

C = [C, br, '\end{tabular}'];

end

% Subfunctions.

%**************************************************************************
function [This,Objs] = xxShareCaption(This,Objs)

tit = Objs{1}.title;
subtit = Objs{1}.subtitle;
form = Objs{1}.options.captiontypeface;

% The caption is shared either if the align option `'sharecaption=' true`,
% or if it is `'auto'` and all captions are the same in all objects in the
% current row.
if isequal(This.options.sharecaption,true)
    flag = true;
elseif isequal(lower(This.options.sharecaption),'auto')
    flag = true;
    for i = 2 : length(Objs)
        if ~strcmp(tit,Objs{i}.title) ...
                || ~strcmp(subtit,Objs{i}.subtitle)
            flag = false;
            break
        end
    end
else
    flag = false;
end

% If all objects in the current row share the same title, the title will be
% printed as part of the align speclatexcode, and we remove the titles from
% the individual objects.
if flag
    for i = 1 : length(Objs)
        Objs{i}.caption = {'',''};
    end
    This.caption = {tit,subtit};
    This.options.captiontypeface = form;
else
    This.caption = {'',''};
end

end % xxShareCaption( )
