function this = mydiff(this, wrt)
% mydiff  Differentiate a sydney expression.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

persistent SYDNEY;
if isnumeric(SYDNEY)
    SYDNEY = sydney( );
end

% @@@@@ MOSW
template = SYDNEY;

%--------------------------------------------------------------------------

nWrt = length(wrt);

% This.lookahead = [ ];
zeroDiff = ~this.lookahead;

% `This` is a sydney object representing a variable name or a number; do
% what's needed and return immediately.
if isempty(this.Func)
    if ischar(this.args)
        % `This` is a variable name.
        if nWrt==1
            % If we differentiate wrt to a single variable, convert the derivative
            % directly to a number `0` or `1` instead of a logical index. This helps
            % reduce some expressions immediately.
            if strcmp(this.args, wrt)
                this = template;
                this.args = 1;
            else
                this = template;
                this.args = 0;
            end
        else
            inx = strcmp(this.args, wrt);
            if any(inx)
                this = template;
                vec = false(nWrt, 1);
                vec(inx) = true;
                this.args = vec;
            else
                this = template;
                this.args = 0;
            end
        end 
    elseif isnumeric(this.args)
        % `This` is a number.
        this = template;
        this.args = 0;
    else
        utils.error('sydney:mydiff','#Internal');
    end
    return
end

% None of the wrt variables occurs in the argument legs of this function.
if all(zeroDiff)
    this = template;
    this.args = 0;
    return
end

switch this.Func
    case 'uplus'
        this = mydiff(this.args{1}, wrt);
    case 'uminus'
        this.args{1} = mydiff(this.args{1}, wrt);
    case 'plus'
        pos = find(~zeroDiff);
        nPos = length(pos);
        if nPos==0
            this = template;
            this.args = 0;
        elseif nPos==1
            this = mydiff(this.args{pos}, wrt);
        else
            args = cell(1, nPos);
            for i = 1 : nPos
                args{i} = mydiff(this.args{pos(i)}, wrt);
            end
            this.args = args;
        end
    case 'minus'
        if zeroDiff(1)
            this.Func = 'uminus';
            this.args = {mydiff(this.args{2}, wrt)};
        elseif zeroDiff(2)
            this = mydiff(this.args{1}, wrt);
        else
            this.args{1} = mydiff(this.args{1}, wrt);
            this.args{2} = mydiff(this.args{2}, wrt);
        end
    case 'times'
        if zeroDiff(1)
            this.args{2} = mydiff(this.args{2}, wrt);
        elseif zeroDiff(2)
            this.args{1} = mydiff(this.args{1}, wrt);
        else
            % mydiff(x1*x2) = mydiff(x1)*x2 + x1*mydiff(x2)
            % Z1 := mydiff(x1)*x2
            % Z2 := x1*mydiff(x2)
            % this := Z1 + Z2
            Z1 = template;
            Z1.Func = 'times';
            Z1.args = {mydiff(this.args{1}, wrt), this.args{2}};
            Z2 = template;
            Z2.Func = 'times';
            Z2.args = {this.args{1}, mydiff(this.args{2}, wrt)};
            this.Func = 'plus';
            this.args = {Z1, Z2};
        end
    case 'rdivide'
        % mydiff(x1/x2)
        if zeroDiff(1)
            this = diffRdivide1( );
        elseif zeroDiff(2)
            this = diffRdivide2( );
        else
            Z1 = diffRdivide1( );
            Z2 = diffRdivide2( );
            this.Func = 'plus';
            this.args = {Z1, Z2};
        end
    case 'log'
        % mydiff(log(x1)) = mydiff(x1)/x1
        this.Func = 'rdivide';
        this.args = {mydiff(this.args{1}, wrt),this.args{1}};
    case 'exp'
        % mydiff(exp(x1)) = exp(x1)*mydiff(x1)
        this.args = {mydiff(this.args{1}, wrt),this};
        this.Func = 'times';
    case 'power'
        pow = this.args{2};
        % diff(x1^0) = 0
        if isequal(pow.args, 0)
            this. Func = '';
            this.args = 0;
            this.lookahead = [ ];
            this.numd = [ ];
            return
        end
        % diff(x1^1) = diff(x1)
        if isequal(pow.args, 1)
            this = mydiff(this.args{1}, wrt);
            return
        end
        if zeroDiff(1)
            % mydiff(x1^x2) with mydiff(x1) = 0
            % mydiff(x1^x2) = x1^x2 * log(x1) * mydiff(x2)
            this = diffPower1( );
        elseif zeroDiff(2)
            % mydiff(x1^x2) with mydiff(x2) = 0
            % mydiff(x1^x2) = x2*x1^(x2-1)*mydiff(x1)
            this = diffPower2( );
        else
            Z1 = diffPower1( );
            Z2 = diffPower2( );
            this.Func = 'plus';
            this.args = {Z1, Z2};
        end
    case 'sqrt'
        % mydiff(sqrt(x1)) = (1/2) / sqrt(x1) * mydiff(x1)
        % Z1 : = 1/2
        % Z2 = Z1 / sqrt(x1) = Z1 / this
        % this = Z2 * mydiff(x1)
        Z1 = template;
        Z1.Func = '';
        Z1.args = 1/2;
        Z2 = template;
        Z2.Func = 'rdivide';
        Z2.args = {Z1,this};
        this.Func = 'times';
        this.args = {Z2, mydiff(this.args{1}, wrt)};
    case 'sin'
        Z1 = this;
        Z1.Func = 'cos';
        this.Func = 'times';
        this.args = {Z1, mydiff(this.args{1}, wrt)};
    case 'cos'
        % mydiff(cos(x1)) = uminus(sin(x)) * mydiff(x1);
        Z1 = this;
        Z1.Func = 'sin';
        Z2 = template;
        Z2.Func = 'uminus';
        Z2.args = {Z1};
        this.Func = 'times';
        this.args = {Z2, mydiff(this.args{1}, wrt)};
    otherwise
        % All other functions -- numerical derivatives.
        % diff(f(x1,x2,...)) = diff(f, 1)*diff(x1) + diff(f,2)*diff(x2) + ...
        pos = find(~zeroDiff);
        nPos = length(pos);
        % diff(f,i)*diff(xi)
        if nPos==1
            Z = diffExternalWrtK(pos(1));
        else
            Z = template;
            Z.Func = 'plus';
            for k = pos
                Z.args{end+1} = diffExternalWrtK(k);
            end
        end
        this = Z;
        
end

return




    function z = diffRdivide1( )
        % Compute mydiff(x1/x2) with mydiff(x1) = 0
        % mydiff(x1/x2) = -x1/x2^2 * mydiff(x2)
        % z1 := -x1
        % z2 := 2
        % z3 := x2^z2
        % z4 :=  z1/z3
        % z := z4*mydiff(x2)
        z1 = template;
        z1.Func = 'uminus';
        z1.args = this.args(1);
        z2 = template;
        z2.Func = '';
        z2.args = 2;
        z3 = template;
        z3.Func = 'power';
        z3.args = {this.args{2}, z2};
        z4 = template;
        z4.Func = 'rdivide';
        z4.args = {z1, z3};
        z = template;
        z.Func = 'times';
        z.args = {z4, mydiff(this.args{2}, wrt)};
    end 




    function z = diffRdivide2( )
        % Compute mydiff(x1/x2) with mydiff(x2) = 0
        % diff(x1/x2) = diff(x1)/x2
        z = template;
        z.Func = 'rdivide';
        z.args = {mydiff(this.args{1}, wrt), this.args{2}};
    end




    function z = diffPower1( )
        % Compute diff(x1^x2) with diff(x1)==0
        % diff(x1^x2) = x1^x2 * log(x1) * diff(x2)
        % z1 := log(x1)
        % z2 := this*z1
        % z := z2*diff(x2)
        z1 = template;
        z1.Func = 'log';
        z1.args = this.args(1);
        z2 = template;
        z2.Func = 'times';
        z2.args = {this, z1};
        z = template;
        z.Func = 'times';
        z.args = {z2, mydiff(this.args{2}, wrt)};
    end



    
    function z = diffPower2( )
        % Compute diff(x1^x2) with diff(x2)==0
        % diff(x1^x2) = x2*x1^(x2-1)*diff(x1)
        % z1 := 1
        % z2 := x2 - z1
        % z3 := f(x1)^z2
        % z4 := x2*z3
        % z := z4*diff(f(x1))
        z1 = template;
        z1.Func = '';
        z1.args = -1;
        z2 = template;
        z2.Func = 'plus';
        z2.args = {this.args{2}, z1};
        z3 = template;
        z3.Func = 'power';
        z3.args = {this.args{1}, z2};
        z4 = template;
        z4.Func = 'times';
        z4.args = {this.args{2}, z3};
        z = template;
        z.Func = 'times';
        z.args = {z4, mydiff(this.args{1}, wrt)};
    end 



    
    function Z = diffExternalWrtK(K)
        if strcmp(this.Func, 'sydney.d')
            z1 = this;
            z1.numd.wrt = [z1.numd.wrt, K];
        else
            z1 = template;
            z1.Func = 'sydney.d';
            z1.numd.Func = this.Func;
            z1.numd.wrt = K;
            z1.args = this.args;
        end
        Z = template;
        Z.Func = 'times';
        Z.args = {z1, mydiff(this.args{K}, wrt)};
    end 
end
