function C = speclatexcode(This)
% speclatexcode  [Not a public function] \LaTeX\ code for userinputobj objects.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%--------------------------------------------------------------------------

br = sprintf('\n');
C = '';

if ~isempty(This.title)
    C = [C,'\begin{tabular}{c}', br ];
    C = [C,printcaption(This), br ];
    C = [C,'\end{tabular}', br ];
end

if isempty(This.userinput)
    return
end

if This.options.verbatim
    C = [C,'\begin{verbatim}'];
elseif ~This.options.centering
    C = [C,'\begin{flushleft}'];
end

C = [C, br, This.userinput];

if This.options.verbatim
    C = [C, br, '\end{verbatim}'];
elseif ~This.options.centering
    C = [C, br, '\end{flushleft}'];
end

C = [C,footnotetext(This)];

end
