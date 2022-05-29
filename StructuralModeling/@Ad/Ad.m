% Ad  Automatic/symbolic differentiator
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

classdef Ad
    properties
        Input = Ad.STRUCT
        Diff = cell.empty(1, 0) %Ad.STRUCT
    end
    
    
    
    
    properties (Constant, Hidden)
        LIST_OF_FUNCTIONS = { 'normcdf'
                              'normpdf'
                              'exp'
                              'log'
                              'sqrt'
                              'power'
                              'mpower'
                              'ldivide'
                              'rdivide'
                              'mldivide'
                              'mrdivide'
                              'times'
                              'mtimes'
                              'minus'
                              'plus'
                              'uminus'
                              'uplus'
                              'Ad.f'     }

        STRUCT = struct('Expression', '', 'Level', Ad.LEVEL_ZERO)
        X0 = struct('Expression', 0, 'Level', 0)
        X1 = struct('Expression', 1, 'Level', 0)
        X2 = struct('Expression', 2, 'Level', 0)
        X_INF = struct('Expression', Inf, 'Level', 0)
        X_HALF = struct('Expression', 0.5, 'Level', 0)
        LEVEL_ZERO = 0
        LEVEL_POWER = 20
        LEVEL_UMINUS = 40
        LEVEL_UPLUS = 40
        LEVEL_DIVIDE = 45
        LEVEL_TIMES = 50
        LEVEL_MINUS = 55
        LEVEL_PLUS = 60
    end
    
    
    
    
    methods
        function this = Ad(nd)
            if nargin==0
                return
            end
            this.Diff = repmat({ Ad.STRUCT }, 1, nd);
        end%
        
        
        
        
        function this = uplus(this)
        end%
        



        function this = ctranspose(this)
        end%
        

        
        
        function this = transpose(this)
        end%
        
        
        
        
        function this = uminus(this)
            this.Input = Ad.lowUminus(this.Input);
            nd = numel(this.Diff);
            for i = 1 : nd
                this.Diff{i} =  Ad.lowUminus(this.Diff{i});
            end
        end%
        
        
        
        
        function this = plus(a, b)
            persistent TEMPLATE
            if ~isa(TEMPLATE, 'Ad')
                TEMPLATE = Ad( );
            end
            this = TEMPLATE;
            if isnumeric(a)
                nd = numel(b.Diff);
                a = Ad.createNumber(a, nd);
            elseif isnumeric(b)
                nd = numel(a.Diff);
                b = Ad.createNumber(b, nd);
            else
                nd = numel(a.Diff);
            end
            this.Input = Ad.lowPlus(a.Input, b.Input);
            this.Diff = cell(1, nd);
            for i = 1 : nd
                this.Diff{i} = Ad.lowPlus(a.Diff{i}, b.Diff{i});
            end
        end%
        
        
        
        
        function this = minus(a, b)
            persistent TEMPLATE
            if ~isa(TEMPLATE, 'Ad')
                TEMPLATE = Ad( );
            end
            this = TEMPLATE;
            if isnumeric(a)
                nd = numel(b.Diff);
                a = Ad.createNumber(a, nd);
            elseif isnumeric(b)
                nd = numel(a.Diff);
                b = Ad.createNumber(b, nd);
            else
                nd = numel(a.Diff);
            end
            this.Input = Ad.lowMinus(a.Input, b.Input);
            this.Diff = cell(1, nd);
            for i = 1 : nd
                this.Diff{i} = Ad.lowMinus(a.Diff{i}, b.Diff{i});
            end
        end%
        
        
        
        
        function this = mtimes(a, b)
            persistent TEMPLATE
            if ~isa(TEMPLATE, 'Ad')
                TEMPLATE = Ad( );
            end
            this = TEMPLATE;
            if isnumeric(a)
                nd = numel(b.Diff);
                a = Ad.createNumber(a, nd);
            elseif isnumeric(b)
                nd = numel(a.Diff);
                b = Ad.createNumber(b, nd);
            else
                nd = numel(a.Diff);
            end
            this.Input = Ad.lowTimes(a.Input, b.Input);
            this.Diff = cell(1, nd);
            for i = 1 : nd
                this.Diff{i} = Ad.lowPlus( Ad.lowTimes(a.Diff{i}, b.Input), ...
                                           Ad.lowTimes(a.Input, b.Diff{i}) );
            end
        end%
        
        
        
        
        function this = times(a, b)
            this = mtimes(a, b);
        end%
        
        
        
        
        function this = mrdivide(a, b)
            persistent TEMPLATE
            if ~isa(TEMPLATE, 'Ad')
                TEMPLATE = Ad( );
            end
            this = TEMPLATE;
            isna = isnumeric(a);
            isnb = isnumeric(b);
            if isna
                nd = numel(b.Diff);
                a = Ad.createNumber(a, nd);
            elseif isnb
                nd = numel(a.Diff);
                b = Ad.createNumber(b, nd);
            else
                nd = numel(a.Diff);
            end
            this.Input = Ad.lowDivide(a.Input, b.Input);
            this.Diff = cell(1, 0);
            for i = 1 : nd
                if isnumeric(b.Diff{i}.Expression) && b.Diff{i}.Expression==0
                    this.Diff{i} = Ad.lowDivide(a.Diff{i}, b.Input);
                    continue
                elseif isnumeric(a.Diff{i}.Expression) && a.Diff{i}.Expression==0
                    this.Diff{i} = Ad.lowTimes(...
                        Ad.lowDivide( ...
                        Ad.lowUminus(a.Input), ...
                        Ad.lowPower(b.Input, Ad.X2) ...
                        ), ...
                        b.Diff{i} ...
                        );
                    continue
                else
                    num = Ad.lowMinus( ...
                        Ad.lowTimes(a.Diff{i}, b.Input), ...
                        Ad.lowTimes(a.Input, b.Diff{i}) ...
                        );
                    den = Ad.lowPower(b.Input, Ad.X2);
                    this.Diff{i} = Ad.lowDivide(num, den);
                    continue
                end
            end
        end%
        
        
        
        
        function this = mldivide(a, b)
            this = mrdivide(b, a);
        end%
        
        
        
        
        function this = rdivide(a, b)
            this = mrdivide(a, b);
        end%
        
        
        
        
        function this = ldivide(a, b)
            this = mrdivide(b, a);
        end%
        
        
        
        
        function this = mpower(a, b)
            persistent TEMPLATE
            if ~isa(TEMPLATE, 'Ad')
                TEMPLATE = Ad( );
            end
            this = TEMPLATE;
            isna = isnumeric(a);
            isnb = isnumeric(b);
            if isna
                nd = numel(b.Diff);
                a = Ad.createNumber(a, nd);
            elseif isnb
                nd = numel(a.Diff);
                b = Ad.createNumber(b, nd);
            else
                nd = numel(a.Diff);
            end
            this.Input = Ad.lowPower(a.Input, b.Input);
            this.Diff = cell(1, nd);
            if ~isna
                % diff[ a(x)^b ] = b*a(x)^(b-1) * diff[ a(x) ]
                if isnb
                    b1 = Ad.STRUCT;
                    b1.Expression = b.Input.Expression - 1;
                else
                    b1 = Ad.lowMinus(b.Input, Ad.X1);
                end
            end
            for i = 1 : nd
                if ~isna
                    % diff[ a(x)^b ] = b*a(x)^(b-1) * diff[ a(x) ]
                    da = Ad.lowTimes( Ad.lowTimes( b.Input, ...
                                                   Ad.lowPower(a.Input, b1) ), ...
                                      a.Diff{i} );
                end
                if ~isnb
                    % diff[ a^b(x) ] = a^b(x) * log(a) * diff[ b(x) ]
                    db = Ad.lowTimes( Ad.lowFunc1('log', a.Input), ...
                                      Ad.lowTimes(this.Input, b.Diff{i}) );
                end
                if ~isna && ~isnb
                    this.Diff{i} = Ad.lowPlus(da, db);
                elseif ~isna
                    this.Diff{i} =  da;
                else
                    this.Diff{i} = db;
                end
            end
        end%
        
        
        
        
        function this = power(a, b)
            this = mpower(a, b);
        end%
        
        
        
        
        function this = sqrt(a)
            persistent TEMPLATE
            if ~isa(TEMPLATE, 'Ad')
                TEMPLATE = Ad( );
            end
            this = TEMPLATE;
            this.Input = Ad.lowFunc1('sqrt', a.Input);
            xh = Ad.STRUCT;
            xh.Expression = 0.5;
            nd = numel(a.Diff);
            this.Diff = cell(1, nd);
            for i = 1 : nd
                this.Diff{i} = Ad.lowTimes( Ad.lowDivide( Ad.X_HALF, ...
                                                          this.Input ), ...
                                            a.Diff{i} );
            end
        end%
        
        
        
        function this = log(a)
            persistent TEMPLATE
            if ~isa(TEMPLATE, 'Ad')
                TEMPLATE = Ad( );
            end
            this = TEMPLATE;
            this.Input = Ad.lowFunc1('log', a.Input);
            nd = numel(a.Diff);
            this.Diff = cell(1, nd);
            for i = 1 : nd
                this.Diff{i} = Ad.lowTimes( Ad.lowDivide(Ad.X1, a.Input), ...
                                            a.Diff{i} );
            end
        end%
        
        
        
        
        function this = exp(a)
            persistent TEMPLATE
            if ~isa(TEMPLATE, 'Ad')
                TEMPLATE = Ad( );
            end
            this = TEMPLATE;
            this.Input = Ad.lowFunc1('exp', a.Input);
            nd = numel(a.Diff);
            this.Diff = cell(1, nd);
            for i = 1 : nd
                this.Diff{i} = Ad.lowTimes(  Ad.lowFunc1('exp', a.Input), ...
                                             a.Diff{i} );
            end
        end%
        
        
        
        
        function this = normpdf(x, varargin)
            persistent TEMPLATE
            if ~isa(TEMPLATE, 'Ad')
                TEMPLATE = Ad( );
            end
            nd = numel(x.Diff);
            n = numel(varargin);
            for i = 1 : n
                if isnumeric(varargin{i})
                    varargin{i} = Ad.createNumber(varargin{i}, nd);
                end
            end
            try
                mu = varargin{1};
            catch
                mu = Ad.createNumber(0, nd);
            end
            try
                sgm = varargin{2};
            catch
                sgm = Ad.createNumber(1, nd);
            end
            this = TEMPLATE;
            this.Input = Ad.lowFuncN('normpdf', x, varargin{:});
            y = exp(-0.5 * ((x - mu)/sgm)^2) / (sqrt(2*pi) * sgm);
            this.Diff = y.Diff;
        end%
        
        
        
        
        function this = normcdf(x, varargin)
            persistent TEMPLATE
            if ~isa(TEMPLATE, 'Ad')
                TEMPLATE = Ad( );
            end
            nd = numel(x.Diff);
            n = numel(varargin);
            for i = 1 : n
                if isnumeric(varargin{i})
                    varargin{i} = Ad.createNumber(varargin{i}, nd);
                end
            end
            try
                mu = varargin{1};
            catch
                mu = Ad.createNumber(0, nd);
            end
            try
                sgm = varargin{2};
            catch
                sgm = Ad.createNumber(1, nd);
            end
            this = TEMPLATE;
            this.Input = Ad.lowFuncN('normcdf', x, varargin{:});
            nd = numel(x.Diff);
            this.Diff = cell(1, nd);
            if n==0
                for i = 1 : nd
                    this.Diff{i} = Ad.lowTimes( ...
                        Ad.lowFuncN('normpdf', x), ...
                        x.Diff{i} ...
                        );
                end
                return
            else
                for i = 1 : nd
                    z = (x-mu)/sgm;
                    this.Diff{i} = Ad.lowTimes( ...
                        Ad.lowFuncN('normpdf', x, varargin{:}), ...
                        z.Diff{i} ...
                        );
                end
                return
            end
        end%
    end
    
    
    
    methods (Static)
        function [d, y] = diff(expn, lsWrt)
            persistent TEMPLATE
            if ~isa(TEMPLATE, 'Ad')
                TEMPLATE = Ad( );
            end
            
            if ischar(lsWrt)
                mode = 1;
                lsWrt = regexp(lsWrt, '\w+', 'match');
            else
                mode = 2;
            end
            numWrt = numel(lsWrt);
            
            listVariables = unique( regexp(expn, '(?<![''\.@])(\<[a-zA-Z]\w*\>)(?![\.\(])', 'match') );
            D = struct( );
            for i = 1:numel(listVariables)
                name = listVariables{i};
                tmp = TEMPLATE;
                tmp.Input.Expression = name;
                if mode==1
                    tmp.Diff = { Ad.X0 };
                else
                    tmp.Diff = repmat( { Ad.X0 }, 1, numWrt);
                end
                D.(name) = tmp;
            end
            
            if numWrt==1
                D.(lsWrt{1}).Diff = { Ad.X1 };
            else
                % wrt = repmat('0;', 1, numWrt);
                wrt = repmat('0,', 1, numWrt);
                if mode==1
                    for i = 1:numWrt
                        name = lsWrt{i};
                        wrt(2*i-1) = '1';
                        % D.(name).Diff{1}.Expression = [' [', wrt(1:end-1), '] '];
                        D.(name).Diff{1}.Expression = [' [', wrt(1:end-1), ']'' '];
                        wrt(2*i-1) = '0';
                    end
                else
                    for i = 1:numWrt
                        name = lsWrt{i};
                        D.(name).Diff{i}.Expression = 1;
                    end
                end
            end
            
            if mode==1
                stringNumDiff = '1';
            else
                stringNumDiff = sprintf('%g', numWrt);
            end

            listFunctions = regexp( expn, ...
                                    '\<[a-zA-Z][\w\.]*\>(?=\()', ...
                                    'match' );
            listFunctions = unique(listFunctions);
            for i = 1:numel(listFunctions)
                if any(strcmp(listFunctions{i}, Ad.LIST_OF_FUNCTIONS))
                    continue
                end
                name = listFunctions{i};
                expn = strrep(expn, [name, '(',], ['Ad.f(''', name, ''',', stringNumDiff, ',']);
            end
            
            for i = 1:numel(listVariables)
                name = listVariables{i};
                expn = regexprep( expn, ...
                                  ['(?<![''\.@])(\<', name, '\>)(?![\.\(])'], ...
                                  ['D___.', name] );
            end
            
            % Ad.eval returns an Ad object (most of the time), or a
            % numerical value if the expression does not involve any
            % unknown.
            y = Ad.eval(D, expn);

            if mode==1
                if isa(y, 'Ad')
                    d = y.Diff{1}.Expression;
                    if isnumeric(d)
                        d = sprintf('%.16g', d);
                    end
                else
                    % If Ad.eval returned a numerical value, all
                    % derivatives are zero.
                    d = '0';
                end
            else
                if isa(y, 'Ad')
                    d = cell(lsWrt);
                    for i = 1 : numWrt
                        d{i} = y.Diff{i}.Expression;
                        if isnumeric(d{i})
                            d{i} = sprintf('%.16g', d{i});
                        end
                    end
                else
                    % If Ad.eval returned a numerical value, all
                    % derivatives are zero.
                    d = repmat({'0'}, 1, numWrt);
                end
            end
        end%
        
        
        
        
        function y = eval(D___, expn) %#ok<INUSL>
            y = eval(expn);
        end%
        
        
        
        
        function expn = postparse(expn)
            expn = Ad.simplify(expn);
        end%
        
        
        
        
        function expn = simplify(expn)
            expn = regexprep(expn, 'exp\(log\(([^\(]+)\)\)', '$1');
            expn = regexprep(expn, 'log\(exp\(([^\(]+)\)\)', '$1');
            expn = strrep(expn, '*1/', '/');
        end%
        
        
        
        
        function this = createNumber(x, nd)
            persistent TEMPLATE
            if ~isa(TEMPLATE, 'Ad')
                TEMPLATE = Ad( );
            end
            this = TEMPLATE;
            this.Input.Expression = x;
            this.Diff = repmat( { Ad.X0 }, 1, nd);
        end%
        
        
        
        
        function y = lowUminus(y)
            if isnumeric(y.Expression)
                y.Expression = -y.Expression;
                return
            end
            if strncmp(y.Expression, '-', 1) && y.Level==Ad.LEVEL_UMINUS
                y.Expression(1) = '';
                return
            end
            if y.Level>Ad.LEVEL_UMINUS
                y.Expression = ['(', y.Expression, ')'];
            end
            y.Expression = ['-', y.Expression];
            y.Level = Ad.LEVEL_UMINUS;
        end%
        
        
        
        
        function y = lowPlus(a, b)
            isna = isnumeric(a.Expression);
            isnb = isnumeric(b.Expression);
            if isna && a.Expression==0
                y = b;
                return
            elseif isnb && b.Expression==0
                y = a;
                return
            end
            y = Ad.STRUCT;
            if isna && isnb
                y.Expression = a.Expression + b.Expression;
                return
            end
            if isna
                a.Expression = sprintf('%.16g', a.Expression);
            elseif isnb
                b.Expression = sprintf('%.16g', b.Expression);
            end
            if b.Expression(1)=='-' || b.Expression(1)=='+'
                y.Expression = [a.Expression, b.Expression];
            elseif a.Expression(1)=='-' || a.Expression(1)=='+'
                y.Expression = [b.Expression, a.Expression];
            else
                y.Expression = [a.Expression, '+', b.Expression];
            end
            y.Level = Ad.LEVEL_PLUS;
        end%
        
        
        
        
        function y = lowMinus(a, b)
            isna = isnumeric(a.Expression);
            isnb = isnumeric(b.Expression);
            if isna && a.Expression==0
                y = Ad.lowUminus(b);
                return
            elseif isnb && b.Expression==0
                y = a;
                return
            end
            y = Ad.STRUCT;
            if isna && isnb
                y.Expression = a.Expression - b.Expression;
                return
            end
            if isna
                a.Expression = sprintf('%.16g', a.Expression);
            elseif isnb
                b.Expression = sprintf('%.16g', b.Expression);
            end
            if isequal(a.Expression, b.Expression)
                y.Expression = 0;
                return
            end
            if b.Level>=Ad.LEVEL_MINUS
                b.Expression = ['(', b.Expression, ')'];
            end
            y.Expression = [a.Expression, '-', b.Expression];
            y.Level = Ad.LEVEL_MINUS;
        end%
        
        
        
        
        function y = lowTimes(a, b)
            isna = isnumeric(a.Expression);
            isnb = isnumeric(b.Expression);
            if isna
                if a.Expression==0
                    y = a;
                    return
                elseif a.Expression==1
                    y = b;
                    return
                elseif a.Expression==-1
                    y = Ad.lowUminus(b);
                    return
                end
            elseif isnb
                if b.Expression==0
                    y = b;
                    return
                elseif b.Expression==1
                    y = a;
                    return
                elseif b.Expression==-1
                    y = Ad.lowUminus(a);
                    return
                end
            end
            y = Ad.STRUCT;
            if isna && isnb
                y.Expression = a.Expression * b.Expression;
                return
            end
            if isna
                a.Expression = sprintf('%.16g', a.Expression);
            elseif isnb
                b.Expression = sprintf('%.16g', b.Expression);
            end
            if a.Level>Ad.LEVEL_TIMES
                a.Expression = ['(', a.Expression, ')'];
            end
            if b.Level>Ad.LEVEL_TIMES
                b.Expression = ['(', b.Expression, ')'];
            end
            y.Expression = [a.Expression, '*', b.Expression];
            y.Level = Ad.LEVEL_TIMES;
        end%
        
        
        
        
        function y = lowDivide(a, b)
            isna = isnumeric(a.Expression);
            isnb = isnumeric(b.Expression);
            if isna && a.Expression==0 && ~isequal(b.Expression, 0)
                y = Ad.X0;
                return
            elseif isnb && b.Expression==1
                y = a;
                return
            elseif isnb && b.Expression==0 && ~isequal(a.Expression, 0)
                y = Ad.X_INF;
                return
            end
            if isequal(a.Expression, b.Expression)
                y = Ad.X1;
                return
            end
            y = Ad.STRUCT;
            if isna && isnb
                y.Expression = a.Expression / b.Expression;
                return
            end
            if isna
                a.Expression = sprintf('%.16g', a.Expression);
            elseif isnb
                b.Expression = sprintf('%.16g', b.Expression);
            end
            if a.Level>Ad.LEVEL_DIVIDE
                a.Expression = ['(', a.Expression, ')'];
            end
            if b.Level>=Ad.LEVEL_DIVIDE
                b.Expression = ['(', b.Expression, ')'];
            end
            y.Expression = [a.Expression, '/', b.Expression];
            y.Level = Ad.LEVEL_DIVIDE;
        end%
        
        
        
        
        function y = lowPower(a, b)
            isna = isnumeric(a.Expression);
            isnb = isnumeric(b.Expression);
            if isnb && b.Expression==0
                y = Ad.X1;
                return
            elseif (isna && a.Expression==1) || (isnb && b.Expression==0)
                y = a;
                return
            elseif isnb && b.Expression==1
                y = a;
                return
            end
            y = Ad.STRUCT;
            if isna && isnb
                y.Expression = a.Expression ^ b.Expression;
                return
            end
            if isna
                a.Expression = sprintf('%.16g', a.Expression);
            elseif isnb
                b.Expression = sprintf('%.16g', b.Expression);
            end
            if a.Level>Ad.LEVEL_POWER
                a.Expression = ['(', a.Expression, ')'];
            end
            if b.Level>Ad.LEVEL_POWER
                b.Expression = ['(', b.Expression, ')'];
            end
            y.Expression = [a.Expression, '^', b.Expression];
            y.Level = Ad.LEVEL_POWER;
        end%
        
        
        
        
        function y = lowFunc1(func, a)
            y = Ad.STRUCT;
            if isnumeric(a.Expression)
                y.Expression = feval(func, a.Expression);
                return
            end
            y.Expression = [func, '(', a.Expression, ')'];
        end%
        
        
        
        
        function y = lowFuncN(name, varargin)
            y = Ad.STRUCT;
            c = [name, '('];
            n = numel(varargin);
            for i = 1 : n
                a = varargin{i};
                if isnumeric(a)
                    string = sprintf('%.16g', a);
                elseif ischar(a)
                    string = ['''', a, ''''];
                elseif isa(a, 'Ad')
                    if isnumeric(a.Input.Expression)
                        string = sprintf('%.16g', a.Input.Expression);
                    else
                        string = a.Input.Expression;
                    end
                end
                c = [c, string]; %#ok<AGROW>
                if i<n
                    c = [c, ',']; %#ok<AGROW>
                end
            end
            c = [c, ')'];
            y.Expression = c;
            y.Level = 0;
        end%
        
        
        
        
        function this = f(name, nd, varargin)
            % nd is either 1 (mode=1) or numWrt (mode=2)
            persistent TEMPLATE
            if ~isa(TEMPLATE, 'Ad')
                TEMPLATE = Ad( );
            end
            this = TEMPLATE;
            this.Input = Ad.lowFuncN(name, varargin{:});
            k = zeros(1, 0);
            if strcmp(name, 'Ad.d')
                name = varargin{1};
                k = varargin{2};
                varargin(1:2) = [ ];
            end
            n = numel(varargin);
            for i = 1 : n
                if isnumeric(varargin{i})
                    varargin{i} = Ad.createNumber(varargin{i}, nd);
                end
            end
            
            d = Ad.lowFuncN(name, varargin{:});
            d.Expression = ['Ad.d(''', name, ''',$,', d.Expression(length(name)+2:end)];
            this.Diff = cell(1, nd);
            for i = 1 : nd
                y = Ad.X0;
                for j = 1 : n
                    di = d;
                    v = sprintf('%g,', [k, j]);
                    v = ['[', v(1:end-1), ']'];
                    di.Expression = strrep(di.Expression, '$', v);
                    y = Ad.lowPlus(y, Ad.lowTimes(di, varargin{j}.Diff{i}));
                end
                y.Level = Ad.LEVEL_PLUS;
                this.Diff{i} = y;
            end
        end%
        
        
        varargout = d(varargin)
        varargout = dn(varargin)
        varargout = shiftBy(varargin)
    end
end

