function C = interpretplain(C)
% interpretplain  [Not a public function] Treat LaTeX special characters in
% string.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

if iscellstr(C)
    for i = 1 : numel(C)
        C{i} = latex.interpretplain(C{i});
    end
    return
end

%--------------------------------------------------------------------------

if isempty(C)
    return
end

% Protect the content of top-level curly braces.
f = fragileobj(C);
[C,f] = protectbraces(C,f);

C = strrep(C,'\','\textbackslash ');
C = strrep(C,'_','\_');
C = strrep(C,'%','\%');
C = strrep(C,'$','\$');
C = strrep(C,'#','\#');
C = strrep(C,'&','\&');
C = strrep(C,'<','\ensuremath{<}');
C = strrep(C,'>','\ensuremath{>}');
C = strrep(C,'~','\ensuremath{\sim}');
C = regexprep(C,'(?<!\.)\.\.\.(?!\.)','\\ldots{ }');

% Put the protected content back.
C = restore(C,f,'delimiter',false);

end
