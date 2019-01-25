function This = rdivide(A,B)
% times  [Not a public function] Overloaded rdivide for sydney class.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2019 IRIS Solutions Team.

persistent SYDNEY;

if isnumeric(SYDNEY)
    SYDNEY = sydney( );
end

%--------------------------------------------------------------------------

This = SYDNEY;
This.args = cell(1,2);
This.Func = 'rdivide';
This.lookahead = false(1,2);

if isnumeric(A)
    x = A;
    A = SYDNEY;
    A.args = x;
    This.lookahead(1) = false;
else
    This.lookahead(1) = any(A.lookahead);
end

if isnumeric(B)
    x = B;
    B = SYDNEY;
    B.args = x;
    This.lookahead(2)= false;
else
    This.lookahead(2) = any(B.lookahead);
end

This.args = {A,B};

end