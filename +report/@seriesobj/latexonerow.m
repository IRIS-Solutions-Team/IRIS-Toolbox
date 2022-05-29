function C = latexonerow(This,Row,Time,Data,Mark,Text)
% latexonerow  [Not a public function] LaTeX code for one table series row.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%--------------------------------------------------------------------------

br = sprintf('\n');
nPer = length(Data);
markString = interpret(This,Mark);
C = [ ...
    doLatexCaption( ), ...
    footnotemark(This), ...
    ' & ',doLatexUnits( ), ...
    ' & ',markString, ...
    latexdata(This,Row,Time,Data,'',Mark,Text), ...
    ' \\', ...
    ];


% Nested functions...


%**************************************************************************


    function C = doLatexCaption( )
        C = '';
        if Row > 1
            return
        end
        tit = interpret(This,This.title);
        subtit = interpret(This,This.subtitle);
        if isempty(subtit)
            C = tit;
            return
        end
        C = ['\multicolumn{3}{l}{',tit,'}', ...
            repmat(' &',1,nPer),' \\',br];
        C = [C,subtit];
    end % doLatexCaption( )


%**************************************************************************


    function C = doLatexUnits( )
        C = '';
        if Row > 1
            return
        end
        C = interpret(This,This.options.units);
        C = ['~',C];
    end % doLatexUnits( )


end
