function C = speclatexcode(This)
% speclatexcode  [Not a public function] \LaTeX\ code for report object.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%--------------------------------------------------------------------------

br = sprintf('\n');
C = '';

if This.options.centering
    C = [C,'\centering', br, br ];
end

C = [C,begintypeface(This)];
nChild = length(This.children);

for i = 1 : nChild

    ch = This.children{i};
    
    % Add a comment before each of the first-level objects.
    C = [C, br, ...
        '%--------------------------------------------------', br, ...
        '% Start of ',shortclass(ch),' ',ch.title]; %#ok<AGROW>
    
    C = [C, br ,begintypeface(ch)]; %#ok<AGROW>
    
    % Generate command-specific latex code.
    c1 = latexcode(ch);

    C = [C,c1,'%']; %#ok<AGROW>
    
    C = [C, br, endtypeface(ch)]; %#ok<AGROW>
    
    if i < nChild
        C = [C, br, ch.options.separator]; %#ok<AGROW>
    end
end

C = [C, br, endtypeface(This)];

end
