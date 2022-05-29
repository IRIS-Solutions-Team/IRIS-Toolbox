function Doc = insertDocSubstitutions(This,Doc,Pkg)
% insertDocSubstitutions  [Not a public function] Insert LaTeX document substitutions into template.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%--------------------------------------------------------------------------

opt = This.options;

timeStamp = opt.timestamp;
if isa(timeStamp,'function_handle')
    timeStamp = timeStamp( );
end
timeStamp = interpret(This,timeStamp);

if nargin < 3
    Pkg = { };
end

br = sprintf('\n');

try
    tempTitle = interpret(This,This.title);
    tempSubtitle = interpret(This,This.subtitle);
    tempHead = tempTitle;
    if ~isempty(tempSubtitle)
        if ~isempty(tempTitle)
            tempTitle = [tempTitle,' \\ '];
            tempHead = [tempHead,' / '];
        end
        tempTitle = [tempTitle,'\mdseries ',tempSubtitle];
        tempHead = [tempHead,tempSubtitle];
    end
    if ~isempty(This.options.footnote)
        titleFootnote = ['\footnote{', ...
            interpret(This,This.options.footnote), ...
            '}'];
    else
        titleFootnote = '';
    end
    Doc = strrep(Doc,'$title$',tempTitle);
    Doc = strrep(Doc,'$titlefootnote$',titleFootnote);
catch
    Doc = strrep(Doc,'$title$','');
    Doc = strrep(Doc,'$titlefootnote$','');
end


try
    Doc = strrep(Doc,'$headertitle$',tempHead);
catch
    Doc = strrep(Doc,'$headertitle$','');
end


try
    Doc = strrep(Doc,'$author$',opt.author);
catch
    Doc = strrep(Doc,'$author$','');
end


try
    Doc = strrep(Doc,'$date$',opt.date);
catch
    Doc = strrep(Doc,'$date$','');
end


try
    Doc = strrep(Doc,'$papersize$',lower(opt.papersize));
catch %#ok<*CTCH>
    Doc = strrep(Doc,'$papersize$','');
end


try
    Doc = strrep(Doc,'$orientation$',lower(opt.orientation));
catch
    Doc = strrep(Doc,'$orientation$','');
end


try
    Doc = strrep(Doc,'$headertimestamp$',timeStamp);
catch
    Doc = strrep(Doc,'$headertimestamp$','');
end


try
    x = opt.textscale;
    if length(x) == 1
        s = sprintf('%g',x);
    else
        s = sprintf('{%g,%g}',x(1),x(2));
    end
    Doc = strrep(Doc,'$textscale$',s);
catch
    Doc = strrep(Doc,'$textscale$','0.75');
end


try
    Doc = strrep(Doc,'$graphwidth$',opt.graphwidth);
catch
    Doc = strrep(Doc,'$graphwidth$','4in');
end


try
    Doc = strrep(Doc,'$fontencoding$',opt.fontenc);
catch
    Doc = strrep(Doc,'$fontencoding$','T1');
end


try
    Doc = strrep(Doc,'$preamble$',opt.preamble);
catch
    Doc = strrep(Doc,'$preamble$','');
end


try
    if ~isempty(Pkg)
        pkgStr = sprintf('\n\\usepackage{%s}',Pkg{:});
        Doc = strrep(Doc,'$packages$',pkgStr);
    else
        Doc = strrep(Doc,'$packages$','');
    end
catch
    Doc = strrep(Doc,'$packages$','');
end


try
    c = sprintf('%g,%g,%g',opt.highlightcolor);
    Doc = strrep(Doc,'$highlightcolor$',c);
catch
    Doc = strrep(Doc,'$highlightcolor$','0.9,0.9,0.9');
end


try %#ok<TRYNC>
    if This.hInfo.package.colortbl
        Doc = strrep(Doc,'% $colortbl$','');
    end
end


try
    if opt.maketitle
        repl = ['\date{',timeStamp,'}', ...
            '\maketitle', ...
            '\thispagestyle{empty}'];
    else
        repl = '';
    end
catch
    repl = '';
end
Doc = strrep(Doc,'$maketitle$',repl);


if opt.maketitle
    try
        if ~isempty(opt.abstract)
            file = file2char(opt.abstract);
            file = textual.convertEndOfLines(file);
            repl = [ ...
                '{\centering', ...
                '\begin{minipage}{$abstractwidth$\textwidth}',br, ...
                '\begin{abstract}\medskip',br,...
                file,br,...
                '\par\end{abstract}',br, ...
                '\end{minipage}',br, ...
                '\par}', ...
                ];
            repl = strrep(repl,'$abstractwidth$', ...
                sprintf('%g',opt.abstractwidth));
        else
            repl = '';
        end
    catch
        repl = '';
    end
end
Doc = strrep(Doc,'$abstract$',repl);


try
    if opt.maketitle
        repl = '\clearpage';
    else
        repl = '';
    end
catch
    repl = '';
end


Doc = strrep(Doc,'$clearfirstpage$',repl);

end
