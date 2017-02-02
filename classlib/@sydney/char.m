function c = char(this)
% char  Print sydney object as text string expression.
%
% Syntax
% =======
%
%     C = char(Z)
%
% Input arguments
% ================
%
% * `Z` [ sydney ] - Sydney object.
%
% Output arguments
% =================
%
% * `C` [ char ] - Text string with an expression representing the input
% sydney object.
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

if isempty(this.Func)
    c = myatomchar(this);
    return
end

if strcmp(this.Func, 'sydney.d')
    % Derivative of an external function.
    c = ['sydney.d(@', this.numd.Func];
    wrt = sprintf(',%g', this.numd.wrt);
    wrt = ['[', wrt(2:end), ']'];
    c = [c, ',', wrt];
    for i = 1 : length(this.args)
        c = [c, ',', arg2char(this.args{i})]; %#ok<AGROW>
    end
    c = [c, ')'];
    return
end

nArg = length(this.args);

if strcmp(this.Func, 'plus')
    doPlus( );
    return
end

if strcmp(this.Func, 'times')
    doTimes( );
    return
end

if nArg==1
    c1 = arg2char(this.args{1});
    switch this.Func
        case 'uplus'
            c = c1;
        case 'uminus'
            if any( strcmp(this.args{1}.Func, {'times', 'rdivide', 'plus', 'minus'}) )
                c1 = [ '(', c1, ')' ];
            end
            c = [ '-', c1 ];
        otherwise
            c = [ this.Func, '(', c1, ')'];
    end
elseif nArg==2
    c1 = arg2char(this.args{1});
    c2 = arg2char(this.args{2});
    isEnclosed = false;
    switch this.Func
        case 'minus'
            sign = '-';
        case 'rdivide'
            sign = '/';
        case 'power'
            sign = '^';
        case 'lt'
            sign = '<';
            isEnclosed = true;
        case 'le'
            sign = '<=';
            isEnclosed = true;
        case 'gt'
            sign = '>';
            isEnclosed = true;
        case 'ge'
            sign = '>=';
            isEnclosed = true;
        case 'eq'
            sign = '==';
            isEnclosed = true;
        otherwise
            sign = '';
    end
    if isempty(sign)
        c = [ this.Func, '(', c1, ',', c2, ')' ];
    else
        if ~isempty(this.args{1}.Func) ...
                && ~strcmp(this.args{1}.Func,'sydney.d')
            c1 = [ '(', c1, ')' ];
        end
        if ~isempty(this.args{2}.Func) ...
                && ~strcmp(this.args{2}.Func,'sydney.d')
            c2 = [ '(', c2, ')' ];
        end
        c = [ c1, sign, c2];
        if isEnclosed
            c = [ '(', c, ')' ];
        end
    end
else
    c = [ this.Func, '(' ];
    c = [ c, arg2char(this.args{1}) ];
    for i = 2 : nArg
        c = [ c, ',', arg2char(this.args{i}) ]; %#ok<AGROW>
    end
    c = [ c, ')' ];
end

if true % ##### MOSW
    % Do nothing.
else
    % Replace `++` and `--` with `+`.
    C = mosw.ppmm(C); %#ok<UNRCH>
end

return
    



    function doPlus( )
        c = '';
        for iiArg = 1 : nArg
            a = this.args{iiArg};
            if strcmp(a.Func,'uminus')
                if ischar(a.args{1})
                    c1 = ['''', a.args{1}, ''''];
                else
                    c1 = char(a.args{1});
                end                
                if any(strcmp(a.args{1}.Func, {'times', 'rdivide', 'plus', 'minus'}))
                    c1 = [ '(', c1, ')' ]; %#ok<AGROW>
                end
                sign = '-';
            elseif isempty(a.Func) && isnumeric(a.args) && all(a.args<0)
                a1 = a;
                a1.args = -a1.args;
                c1 = myatomchar(a1);
                sign = '-';
            else
                if ischar(a)
                    c1 = ['''', a, ''''];
                else
                    c1 = char(a);
                end
                sign = '+';
            end
            c = [ c, sign, c1 ]; %#ok<AGROW>
        end
        if c(1)=='+'
            c(1) = '';
        end
    end 




    function doTimes( )
        c = '';
        for iiArg = 1 : nArg
            a = this.args{iiArg};
            if ischar(a)
                c1 = ['''', a, ''''];
            else
                c1 = char(a);
            end
            if any( strcmp(a.Func, {'rdivide', 'plus', 'minus'}) )
                   c1 = [ '(', c1, ')' ]; %#ok<AGROW>
            end
            c = [ c, '*', c1 ]; %#ok<AGROW>
        end
        if c(1)=='*'
            c(1) = '';
        end
    end
end




% Print one input argument into a function call; if it is a string  we need
% to enclose it in single quotes.
function c = arg2char(a)
if ischar(a)
    c = ['''', a, ''''];
else
    c = char(a);
end
end
