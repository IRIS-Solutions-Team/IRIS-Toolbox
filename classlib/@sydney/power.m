function this = power(a, b)
% times  Overloaded power and mpower for sydney class.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

persistent SYDNEY;

if isnumeric(SYDNEY)
    SYDNEY = sydney( );
end

%--------------------------------------------------------------------------

this = SYDNEY;
this.args = cell(1, 2);
this.Func = 'power';
this.lookahead = false(1, 2);

if isnumeric(a)
    if a==1
        this.Func = '';
        this.args = 1;
        this.lookahead = false;
        return
    end
    x = a;
    a = SYDNEY;
    a.args = x;
    this.lookahead(1) = false;
else
    this.lookahead(1) = any(a.lookahead);
end

if isnumeric(b)
    if b==0
        this = SYDNEY;
        this.Func = '';
        this.args = 1;
        this.lookahead = false;
        return
    elseif b==1
        this = a;
        return
    end
    x = b;
    b = SYDNEY;
    b.args = x;
    this.lookahead(2) = false;
else
    this.lookahead(2) = any(b.lookahead);
end

this.args = {a, b};

end