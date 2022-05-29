function [C,This] = protectquotes(C,This)
% protectquotes  [Not a public function] Replace quoted strings with
% replacement codes, and store the original content.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%--------------------------------------------------------------------------

ptn = '([''"])([^\n]*?)\1';
replaceFunc = @doReplace; %#ok<NASGU>
C = regexprep(C,ptn,'${replaceFunc($1,$2)}');

return

    
    
    
    function K = doReplace(Quote,String)
        This.Store{end+1} = String;
        This.Open{end+1} = Quote;
        This.Close{end+1} = Quote;
        K = charcode(This);
    end % doReplace( )
    



end
