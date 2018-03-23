function C = printmodelfile(This)
% printmodelfile  [Not a public function] LaTeXify and syntax highlight model file.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

%--------------------------------------------------------------------------

% TODO: Handle comment blocks %{...%} properly.
C = '';
if isempty(This.filename)
    return
end
isModel = ~isempty(This.modelobj) && isa(This.modelobj,'model');
if isModel
    pList = get(This.modelobj,'pList');
    eList = get(This.modelobj,'eList');
end
br = sprintf('\n');

% Read the text file into a cellstr with EOLs removed.
file = file2char(This.filename,'cellstr');
if isequal(This.options.lines,@all)
    nLine = length(file);
    This.options.lines = 1 : nLine;
else
    file = file(This.options.lines);
end

% Choose escape character.
escList = '`@?$#~&":|!^[ ]{ }<>';
esc = xxChooseEscChar(file,escList);
if isempty(esc)
    utils.error('report', ...
        ['Cannot print the model file. ', ...
        'Make sure at least on of these characters completely disappears ', ...
        'from the model file: %s.'], ...
        escList);
end
verbEsc = ['\verb',esc];

nDigit = ceil(log10(max(This.options.lines)));

C = [C,'\definecolor{mylabel}{rgb}{0.55,0,0.35}',br];
C = [C,'\definecolor{myparam}{rgb}{0.90,0,0}',br];
C = [C,'\definecolor{mykeyword}{rgb}{0,0,0.75}',br];
C = [C,'\definecolor{mycomment}{rgb}{0,0.50,0}',br];

for i = 1 : nLine
    c = doOneLine(file{i});
    C = [C,c,' \\',br]; %#ok<AGROW>
end

C = strrep(C,['\verb',esc,esc],'');


% Nested functions...


%**************************************************************************

    
    function C = doOneLine(C)
        labels = fragileobj(C);
        [C,labels] = protectquotes(C,labels);
        
        lineComment = '';
        pos = strfind(C,'%');
        if ~isempty(pos)
            pos = pos(1);
            lineComment = C(pos:end);
            C = C(1:pos-1);
        end

        if This.options.syntax
            % Keywords.
            if true % ##### MOSW
                keywordsFunc = @doKeywords; %#ok<NASGU>
                C = regexprep(C, ...
                    '!!|!\<\w+\>|=#|&\<\w+>|\$.*?\$', ...
                    '${keywordsFunc($0)}');
            else
                C = mosw.dregexprep(C, ...
                    '!!|!\<\w+\>|=#|&\<\w+>|\$.*?\$', ...
                    @doKeywords,0); %#ok<UNRCH>
            end
            % Line comments.
            if ~isempty(lineComment)
                lineComment = [ ...
                    esc, ...
                    '{\color{mycomment}', ...
                    verbEsc,lineComment,esc, ...
                    '}', ...
                    verbEsc];
            end
        end
        
        if isModel && This.options.paramvalues
            % Find words not preceeded by an !; whether they really are
            % parameter names or std errors is verified within doParamVal.
            if true % ##### MOSW
                paramValFunc = @doParamVal; %#ok<NASGU>
                C = regexprep(C, ...
                    '(?<!!)\<\w+\>', ...
                    '${paramValFunc($0)}');
            else
                C = mosw.dregexprep(C, ...
                    '(?<!!)\<\w+\>', ...
                    @doParamVal,0); %#ok<UNRCH>
            end
        end
        
        if This.options.linenumbers
            C = [ ...
                sprintf('%*g: ',nDigit,This.options.lines(i)), ...
                C];
        end
        
        % Put labels back into the model code.
        labels1 = xxLabelSyntax(labels, ...
            esc,This.options.syntax,This.options.latexalias);
        C = restore(C,labels1);
        
        % Put labels back into comments; no syntax colouring or latexing aliases.
        labels2 = xxLabelSyntax(labels,esc,false,false);
        lineComment = restore(lineComment,labels2);

        C = [verbEsc,C,lineComment,esc];
        
        function C = doKeywords(C)
            if strcmp(C,'!!') || strcmp(C,'=#') ...
                    || strncmp(C,'&',1) || strncmp(C,'$',1)
                color = 'red';
            else
                color = 'mykeyword';
            end
            C = [ ...
                '{\color{',color,'}', ...
                verbEsc,C,esc, ...
                '}', ...
                ];
            C = [esc,C,verbEsc];
        end
        
        function C = doParamVal(C)
            if any(strcmp(C,eList))
                value = This.modelobj.(['std_',C]);
                prefix = '\sigma\!=\!';
            elseif any(strcmp(C,pList))
                value = This.modelobj.(C);
                prefix = '';
            else
                return
            end
            value = sprintf('%g',value(1));
            value = strrep(value,'Inf','\infty');
            value = strrep(value,'NaN','\mathrm{NaN}');
            value = ['{\color{myparam}$\left<{', ...
                prefix,value,'}\right>$}'];
            C = [C,esc,value,verbEsc];
        end
    end % doOneLine( )

end


% Subfunctions...


%**************************************************************************


function Labels = xxLabelSyntax(Labels,Esc,IsSyntax,IsLatexAlias)

verbEsc = ['\verb',Esc];

for i = 1 : length(Labels.Store)
    text = Labels.Store{i};
    open = Labels.Open{i};
    close = Labels.Close{i};
    split = strfind(text,'!!');
    if ~isempty(split)
        split = split(1);
        label = text(1:split+1);
        alias = text(split+2:end);
        if IsLatexAlias
            alias = [Esc,alias,verbEsc]; %#ok<AGROW>
        end
    else
        label = text;
        alias = '';
    end
    
    if IsSyntax
        open = [Esc,'{\color{mylabel}',verbEsc,open]; %#ok<AGROW>
        close = [close,Esc,'}',verbEsc]; %#ok<AGROW>
    end
    
    Labels.Store{i} = [label,alias];
    Labels.Open{i} = open;
    Labels.Close{i} = close;
end

end % xxLabelsBack( )


%**************************************************************************


function Esc = xxChooseEscChar(File,EscList)
File = [File{:}];
Esc = '';
for i = 1 : length(EscList)
    if isempty(strfind(File,EscList(i)))
        Esc = EscList(i);
        break
    end
end

end % xxChooseEscChar( )
