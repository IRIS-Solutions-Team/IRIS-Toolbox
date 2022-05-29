function [c, author, event] = xml2tex(X, opt)
% xml2tex  Convert published XML to LaTeX code.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%--------------------------------------------------------------------------

% First input can be either a xml dom or a xml file name.
if ischar(X)
    X = xmlread(X);
end

parseOriginalCode(X);
replaceBookmarks( );

% Overview cell (introduction).
[c,author,event] = parseIntroduction(X, opt);

% Table of contents.
c = [c,addToc(X,opt)];

% Normal cells.
y = latex.xml.xpath(X,'//cell[not(@style="overview")]','nodeset');
n = y.getLength( );
for i = 1 : n
    c = [c,parseNormalCell(y.item(i-1))];
end

% Fix idiosyncrasies.
c = resolveList(c);

end




function C = replaceBookmarks(B)
persistent BOOKMARKS;
if nargin == 0 && nargout == 0
    code = parseOriginalCode( );
    BOOKMARKS = regexp(code,'%\?(\w+)\?','tokens');
    BOOKMARKS = [BOOKMARKS{:}];
    [~,inx] = unique(BOOKMARKS,'first');
    BOOKMARKS = BOOKMARKS(sort(inx));
    return
end
C = '';
if ischar(B)
    inx = strcmp(B,BOOKMARKS);
    if any(inx)
        C = sprintf('%g',find(inx,1)); % typeset{inx};
    else
        C = '?';
    end
    C = ['\bookmark{',C,'}'];
end
end 




function [c, author, event] = parseIntroduction(X, Opt)
c = '';
BR = sprintf('\n');
[~, ftit, fext] = ...
    fileparts(latex.xml.xpath(X, '//filename', 'string')); %#ok<ASGLU>
% Read title.
title = latex.xml.xpath(X,'//cell[@style="overview"]/steptitle','node');
title = parseText(title);
title = strtrim(title);

if isempty(title)
    error('Empty title.');
end

superTitle = '';
pos = strfind(title, '//');
if ~isempty(pos)
    superTitle = strtrim( title(1:pos(1)-1) );
    title = strtrim( title(pos(1)+3:end) );
elseif ~isempty(Opt.supertitle)
    superTitle = strtrim(Opt.supertitle);
end

isEmptySuperTitle = isempty(superTitle);

% Read first paragraph and check if it gives the authors.
author = NaN;
event = NaN;
p = latex.xml.xpath(X, ...
    '//cell[@style="overview"]/text/p[position()=1]','node');
if ~isempty(p)
    temp = strtrim(char(p.getTextContent( )));
    if strncmp(temp,'by ',3)
        author = temp(4:end);
        author = strrep(author,'&',' \\ ');
        if ~isempty(strfind(author,' \\ '))
            author = ['\\ ',author];
        end
        % Remove the first paragraph.
        p.getParentNode.removeChild(p);
    elseif strncmp(temp,'at ',3)
        event = temp(4:end);
        % Remove the first paragraph.
        p.getParentNode.removeChild(p);
    end
end
% Read abstract.
abstract = latex.xml.xpath(X,'//cell[@style="overview"]/text','node');
abstract = parseText(abstract);
abstract = strtrim(abstract);

% Read file title.
if isEmptySuperTitle
    c = [c, '\mytitle{', title, '}', BR];
    fileTitle = title;
else
    c = [c, '\mytitle{', superTitle, ':\\ ', title, '}', BR];
    fileTitle = [superTitle, ': ', title];
end
if ~isempty(abstract)
    c = [c,'\begin{myabstract}',abstract,'\end{myabstract}',BR];
end

c = [c, '\renewcommand{\filetitle}{', fileTitle, '}', BR];
c = [c,BR,'\bigskip\par'];

c = [c,BR,BR];
end




function C = addToc(~,Opt)
br = sprintf('\n');
C = '';
if ~Opt.toc
    return
end
C = [C,'\mytableofcontents',br,br];
end




function C = parseNormalCell(X)
br = sprintf('\n');
title = strtrim(latex.xml.xpath(X,'steptitle','string'));
if all(strcmpi(title, '...'))
    cBegin = '\begin{splitcell}';
    cEnd = '\end{splitcell}';
else
    cBegin = ['\begin{cell}{',title,'}'];
    cEnd = '\end{cell}';
end
C = '';
% Intro text.
c1 = parseText(latex.xml.xpath(X,'text','node'));
if ~isempty(c1)
    C = [C,'\begin{introtext}',br];
    C = [C,c1,br];
    C = [C,'\end{introtext}',br];
end
% Input code.
y = latex.xml.xpath(X,'mcode','node');
if ~isempty(y)
    inpCode = char(y.getTextContent( ));
    inpCode = textual.convertEndOfLines(inpCode);
    inpCode = textfun.removetrails(inpCode);
    [~,n] = parseOriginalCode(inpCode);
    
    replace = @replaceBookmarks; %#ok<NASGU>
    inpCode = regexprep( ...
        inpCode ...
        , "%\?(\w+)\?" ...
        , "`${replace($1)}`" ...
    );
    
    C = [C,br, ...
        '\begin{inputcode}',br, ...
        '\lstset{firstnumber=',sprintf('%g',n),'}',br, ...
        '\begin{lstlisting}',br, ...
        inpCode, ...
        '\end{lstlisting}',br, ...
        '\end{inputcode}'];
end
% Output code.
outputCode = latex.xml.xpath(X,'mcodeoutput','node');
if ~isempty(outputCode)
    outputCode = char(outputCode.getTextContent( ));
    outputCode = textual.convertEndOfLines(outputCode);
    C = [C,br, ...
        '\begin{outputcode}',br, ...
        '\begin{lstlisting}',br, ...
        outputCode, ...
        '\end{lstlisting}',br, ...
        '\end{outputcode}',br];
end
% Images that are part of code output.
images = latex.xml.xpath(X,'img','nodeset');
nImg = images.getLength( );
if nImg > 0
    for iImg = 1 : nImg
        C = [C,insertImg(images.item(iImg-1))];
    end
end
C = [cBegin,br,C,br,cEnd,br,br];
end




function [Code1,N] = parseOriginalCode(X)
persistent CODE;
try %#ok<TRYNC>
    if ~ischar(X)
        % Initialise `originalcode` when `x` is an xml dom.
        CODE = latex.xml.xpath(X,'//originalCode','string');
        CODE = textual.convertEndOfLines(CODE);
        CODE = textfun.removetrails(CODE);
    end
end
Code1 = CODE;
if nargout < 2
    return
end
nCode = length(X);
start = strfind(CODE,X);
if isempty(start)
    disp(X);
    utils.error('latex', ...
        'The above m-file code segment not found.');
end
start = start(1);
finish = start + nCode - 1;
N = sum(CODE(1:start-1) == char(10)) + 1;
nReplace = sum(X == char(10));
replace = char(10*ones(1,nReplace));
CODE = [CODE(1:start-1),replace,CODE(finish+1:end)];
end 




function C = parseText(X)
C = '';
if isempty(X)
    return
end
br = sprintf('\n');
X = latex.xml.xpath(X,'node()','nodeset');
n = X.getLength( );
for i = 1 : n
    this = X.item(i-1);
    switch char(this.getNodeName)
        case 'latex'
            c1 = char(this.getTextContent( ));
            c1 = strrep(c1,'<latex>','');
            c1 = strrep(c1,'</latex>','');
            C = [C,br,br,c1,br]; %#ok<*AGROW>
        case 'p'
            % Paragraph.
            C = [C,br,'\begin{par}',parseText(this), ...
                '\end{par}'];
        case 'a'
            % Bookmark in the text.
            c1 = char(this.getTextContent( ));
            if ~isempty(c1) && all(c1([1,end]) == '?')
                c1 = replaceBookmarks(c1(2:end-1));
            else
                c1 = parseText(this);
                c1 = ['\texttt{\underline{',c1,'}}'];
            end
            C = [C,c1];
        case 'b'
            C = [C,'\textbf{',parseText(this),'}'];
        case 'i'
            C = [C,'\textit{',parseText(this),'}'];
        case 'tt'
            % C = [C,'{\codesize\texttt{', parseText(this), '}}'];
            c1 = char(this.getTextContent( ));
            C = [C,'{\codesize\verb`', c1, '`}'];
        case 'ul'
            C = [C,'\begin{itemize}',parseText(this), ...
                '\end{itemize}'];
        case 'ol'
            C = [C,'\begin{enumerate}',parseText(this), ...
                '\end{enumerate}'];
        case 'li'
            c1 = strtrim(parseText(this));
            n = length('\bookmark{');
            if strncmp(c1,'\bookmark{',n)
                % Item starting with a bookmark.
                close = textfun.matchbrk(c1,n);
                if isempty(close)
                    close = 0;
                end
                C = [C,'\item[',c1(1:close),'] ',c1(close+1:end)];
            else
                % Regular item.
                C = [C, '\item ', c1];
            end
        case 'pre'
            % If this is a <pre class="error">, do not display
            % anything.
            if ~strcmp(char(this.getAttribute('class')), 'error')
                c1 = char(this.getTextContent( ));
                C = [C, '{\codesize\begin{verbatim}', c1, ...
                    '\end{verbatim}}'];
            end
        case 'img'
            % This is an equation converted successfully to an image.
            % Retrieve the original latex code from the attribute alt.
            % We do not need to capture the name of the source image
            % because it is inside the temp directory, and will be
            % deleted at the end.
            if strcmp(char(this.getAttribute('class')),'equation')
                alt = char(this.getAttribute('alt'));
                C = [C,alt];
            end
        case 'equation'
            % An equation element either contains a latex code directly
            % (if conversion to image failed), or an image element.
            c1 = char(this.getTextContent( ));
            c1 = strtrim(c1);
            if isempty(c1)
                % Image element.
                c1 = parseText(this);
                c1 = strtrim(c1);
            end
            C = [C, c1];
        otherwise
            c1 = char(this.getTextContent( ));
            c1 = regexprep(c1, '\s+', ' ');
            c1 = latex.replaceSpecChar(c1);
            C = [C, c1];
    end
end
end



function C = resolveList(C)
C = regexprep(C, ...
    '\\end\{itemize\}\s*\\begin\{itemize\}', ...
    '');
C = regexprep(C, ...
    '\\end\{enumerate\}\s*\\begin\{enumerate\}', ...
    '');
end




function C = insertImg(X)
% File name in the `src` attribute is a relative path wrt the original
% directory. We only need to refer to the file name.
fName = latex.xml.xpath(X,'@src','string');
[~,fTitle,fExt] = fileparts(fName);
C = '';
if exist([fTitle, fExt], 'file')~=2
    utils.warning('xml', ...
        'Image file not found: %s.',[fTitle,fExt]);
    return
end
if all(strcmpi(fExt, '.eps'))
    latex.epstopdf([fTitle,fExt]);
    fExt = '.pdf';
end
br = sprintf('\n');
C = [br,'\matlabfigure{',[fTitle,fExt],'}',br];
end
