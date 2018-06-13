function specdisp(This)
% specdisp  [Not a public function] Subclass specific disp line.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

%--------------------------------------------------------------------------

specdisp@VAR(This);

fprintf('\tidentification: ');
if ~isempty(This.Method)
    u = unique(This.Method);
    fprintf('%s',textfun.displist(u));
else
    fprintf('empty');
end
fprintf('\n');

end
