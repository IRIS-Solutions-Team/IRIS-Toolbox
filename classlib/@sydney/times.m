function this = times(a, b)
% times  Overloaded times and mtimes for sydney class.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

persistent SYDNEY;

if isnumeric(SYDNEY)
    SYDNEY = sydney( );
end

%--------------------------------------------------------------------------

this = SYDNEY;
this.args = cell(1, 2);
this.Func = 'times';
this.lookahead = false(1, 2);

isZeroA = isequal(a, 0) || (~isnumeric(a) && isequal(a.args, 0));
isZeroB = isequal(b, 0) || (~isnumeric(b) && isequal(b.args, 0));
if isZeroA || isZeroB
    this = SYDNEY;
    this.args = 0;
    this.lookahead = false;
    return
end

if isnumeric(a)
    if a==0
        this = SYDNEY;
        this.Func = '';
        this.args = 0;
        this.lookahead = false;
        return
    elseif a==1
        this = b;
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
        this.args = 0;
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
