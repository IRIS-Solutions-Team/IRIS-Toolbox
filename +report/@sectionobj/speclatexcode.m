function C = speclatexcode(This,~)
% speclatexcode  [Not a public function] Produce LaTeX code for section objects.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%--------------------------------------------------------------------------

if isempty(This.caption)
    C = '';
    return
end

if This.options.numbered
    numbered = '';
else
    numbered = '*';
end

C = interpret(This,This.caption);
C = ['\section',numbered,'{',C,'}'];

end
