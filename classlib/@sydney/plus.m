function this = plus(a, b)
% plus  Overloaded plus for sydney class.
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

this = SYDNEY;
this.Func = 'plus';

isZeroA = isequal(a, 0) || (~isnumeric(a) && isequal(a.args, 0));
isZeroB = isequal(b, 0) || (~isnumeric(b) && isequal(b.args, 0));
if isZeroA || isZeroB
    if isZeroA && isZeroB
        this = SYDNEY;
        this.args = 0;
        this.lookahead = false;
        return
    elseif isZeroA
        if isnumeric(b)
            this = SYDNEY;
            this.args = b;
            this.lookahead = false;
            return
        else
            this = b;
            return
        end
    else
        if isnumeric(a)
            this = SYDNEY;
            this.args = a;
            this.lookahead = false;
            return
        else
            this = a;
            return
        end
    end
end

isNumericB = isnumeric(b);
isPlusB = ~isNumericB && strcmp(b.Func, 'plus');

if isnumeric(a)
    x = a;
    a = SYDNEY;
    a.args = x;
    this.args = {a}; 
    this.lookahead = false;
elseif strcmp(a.Func, 'plus')
    if ~isNumericB && ~isPlusB
        this.args = [a.args, {b}];
        this.lookahead = [a.lookahead, any(b.lookahead)];
        return
    end  
    this.args = a.args;
    this.lookahead = a.lookahead;
else
    if ~isNumericB && ~isPlusB
        this.args = {a, b};
        this.lookahead = [any(a.lookahead), any(b.lookahead)];
        return
    end
    this.args = {a};
    this.lookahead = any(a.lookahead);
end

if isNumericB
    x = b;
    b = SYDNEY;
    b.args = x;
    this.args = [this.args, {b}]; 
    this.lookahead = [this.lookahead, false];
elseif isPlusB
    this.args = [this.args, b.args];
    this.lookahead = [this.lookahead, b.lookahead];
else
    this.args = [this.args, {b}];
    this.lookahead = [this.lookahead, any(b.lookahead)];
end

end