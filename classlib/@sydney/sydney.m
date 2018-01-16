classdef sydney
    % sydney  Automatic first-order differentiator.
    %
    % Backend IRIS class.
    % No help provided.
    
    % -IRIS Macroeconomic Modeling Toolbox.
    % -Copyright (c) 2007-2018 IRIS Solutions Team.
    
    properties
        Func = '';
        args = cell(1, 0);
        lookahead = [ ];
        numd = [ ];
    end
    
    
    
    
    % The following functions can be called directly on sydney objects; all
    % other functions need are replaced with the string
    % `'sydney.parse(func,...)'` in `callfunc( )`.
    properties (Constant)
        LS_FUNCTION = { ...
            'atan', ...
            'cos', ...
            'exp', ...
            'ldivide', ...
            'log', ...
            'log10', ...
            'minus', ...
            'mldivide', ...
            'mpower', ...
            'mrdivide', ...
            'mtimes', ...
            'normcdf', ...
            'normpdf', ...
            'plus', ...
            'power', ...
            'rdivide', ...
            'reduce', ...
            'sin', ...
            'sqrt', ...
            'sydney', ...
            'tan', ...
            'times', ...
            'uminus', ...
            'uplus', ...
            };
    end
    
    
    methods
        function this = sydney(varargin)
            if isempty(varargin)
                return
                
            elseif length(varargin)==1 && isa(varargin{1}, 'sydney')
                
                % Sydney object.
                this = varargin{1};
                return
                
            else
                
                expn = varargin{1};
                try
                    wrt = varargin{2};
                catch
                    wrt = '';
                end
                
                if isnumeric(expn)
                    
                    % Plain number.
                    this.Func = '';
                    this.args = expn;
                    this.lookahead = false;
                    
                elseif ischar(expn)
                    
                    if isvarname(expn)
                        
                       % Single variable name.
                        this.Func = '';
                        this.args = expn;
                        this.lookahead = any(strcmp(expn,wrt));
                        
                    else
                        
                        % General expression.
                        template = sydney( );
                        expr = strtrim(expn);
                        if isempty(expr)
                            this.Func = '';
                            this.args = 0;
                            return
                        end
                        
                        % Remove anonymous function header @(...) if present.
                        if strncmp(expr,'@(',2)
                            expr = regexprep(expr, '@\(.*?\)', '');
                        end
                        
                        % Find all variables names.
                        varList = regexp(expr, ...
                            '(?<!@)(\<[a-zA-Z]\w*\>)(?!\()', 'tokens');
                        
                        % Validate function names in the equation. Function
                        % not handled by the sydney class will be evaluated
                        % by a call to sydney.parse( ).
                        expr = sydney.callfunc(expr);
                        if ~isempty(varList)
                            varList = unique([varList{:}]);
                        end
                        
                        
                        
                        % Create a sydney object for each variables name.
                        nVar = length(varList);

                        z = cell(1,nVar);
                        %z(:) = {template};
                        for i = 1 : nVar
                            name = varList{i};
                            z{i} = template;
                            z{i}.args = name;
                            z{i}.lookahead = any(strcmp(name,wrt));
                        end
                                                
                        % Create an anonymous function for the expression.
                        % The function's preamble includes all variable
                        % names found in the equation.
                        preamble = sprintf('%s,', varList{:});
                        preamble = preamble(1:end-1);
                        preamble = [ '@(', preamble, ')' ];
                        if true % #####
                            tempFunc = str2func([preamble, expr]);
                        else
                            tempFunc = mosw.str2func([preamble, expr]); %#ok<UNRCH>
                        end
                        
                        % Evaluate the equation's function handle on the
                        % sydney objects.
                        x = tempFunc(z{:});
                                                
                        if isa(x,'sydney')
                            this = x;
                        elseif isnumeric(x)
                            this.Func = '';
                            this.args = x;
                            this.lookahead = false;
                        else
                            utils.error('sydney', ...
                                'Cannot create a sydney object.');
                        end
                        
                    end
                end
                
            end
        end
        
        varargout = uminus(varargin)
        varargout = plus(varargin)
        varargout = times(varargin)
        varargout = rdivide(varargin)
        varargout = power(varargin)
        
        varargout = derv(varargin)
        varargout = myatomchar(varargin)
        varargout = mydiff(varargin)
        varargout = myeval(varargin)
        varargout = reduce(varargin)
        varargout = char(varargin)
        
        function This = uplus(A)
            This = A;
        end

        function This = minus(A, B)
            % Replace x - y with x + (-y) to include minus as a special case in plus
            % with multiple arguments.
            This = plus(A, uminus(B));
        end
        
        function This = mtimes(A, B)
            This = times(A, B);
        end
        
        function This = mrdivide(A, B)
            This = rdivide(A, B);
        end
        function This = ldivide(A, B)
            This = rdivide(B,A);
        end
        function This = mldivide(A, B)
            This = rdivide(B,A);
        end
        function This = mpower(A, B)
            % Reduce 10^(log10(x)) to x.
            if ( (isnumeric(A) && isequal(A, 10)) ...
                    || (isa(A, 'sydney') && isnumber(A, 10)) ) ...
                    && strcmp(B.Func,'log10')
                This = B.args{1};
                return
            end
            This = power(A, B);
        end
        function This = normpdf(varargin)
            This = sydney.parse('normpdf', varargin{:});
        end
        function This = normcdf(varargin)
            This = sydney.parse('normcdf', varargin{:});
        end
        function This = exp(X)
            % Reduce exp(log(x)) to x.
            if strcmp(X.Func,'log')
                This = X.args{1};
                return
            end
            This = sydney.parse('exp', X);
        end
        function This = log(X)
            % Reduce log(exp(x)) to x.
            if strcmp(X.Func,'exp')
                This = X.args{1};
                return
            end
            This = sydney.parse('log', X);
        end
        function This = log10(X)
            % Reduce log10(10^x) to x.
            if strcmp(X.Func,'power') && isnumber(X.args{1},10)
                This = X.args{2};
                return
            end
            This = sydney.parse('log10', X);
        end
        function This = sqrt(varargin)
            This = sydney.parse('sqrt', varargin{:});
        end
        function This = atan(varargin)
            This = sydney.parse('atan', varargin{:});
        end
        function This = sin(varargin)
            This = sydney.parse('sin', varargin{:});
        end
        function This = tan(varargin)
            This = sydney.parse('tan', varargin{:});
        end
        function This = cos(varargin)
            This = sydney.parse('cos', varargin{:});
        end
        
        
        function This = gt(varargin)
            This = sydney.parse('gt', varargin{:});
        end
        function This = ge(varargin)
            This = sydney.parse('ge', varargin{:});
        end
        function This = lt(varargin)
            This = sydney.parse('lt', varargin{:});
        end
        function This = le(varargin)
            This = sydney.parse('le', varargin{:});
        end
        function This = eq(varargin)
            This = sydney.parse('eq', varargin{:});
        end
        function Flag = isnumber(Z, X)
            Flag = isempty(Z.Func) && isnumericscalar(Z.args);
            try %#ok<TRYNC>
                Flag = Flag && isequal(Z.args, X);
            end
        end
    end
    

    
    methods (Static)
        function expr = callfunc(expr)
            % Find all function names. Function names may also include dots to allow
            % for methods and packages. Functions with no input arguments are not
            % parsed and remain unchanged.
            lsFunc = regexp( ...
                expr, ...
                '(\<[a-zA-Z][\w\.]*\>)\((?!\))', ...
                'tokens' ...
                );
            if isempty(lsFunc)
                return
            end
            lsFunc = [ lsFunc{:} ];
            lsFunc = unique(lsFunc);
            % Find calls to functions that are not handled directly within the sydney
            % class.
            lsFunc = setdiff(lsFunc, sydney.LS_FUNCTION);
            for i = 1 : length(lsFunc)
                name = lsFunc{i};
                expr = regexprep( ...
                    expr, ...
                    ['\<',name,'\>\('], ...
                    ['sydney.parse(''',name,''','] ...
                    );
            end
        end
    end
    
    
    methods (Static)    
        varargout = d(varargin)
        varargout = mydiffeqtn(varargin)
        varargout = myshift(varargin)
        varargout = mysymb2eqtn(varargin)
        varargout = myeqtn2symb(varargin)
        varargout = parse(varargin)

        % For bkw compatibility.
        function varargout = diffxf(varargin)
            [varargout{1:nargout}] = sydney.d(varargin{:});
        end
        function varargout = numdiff(varargin)
            [varargout{1:nargout}] = sydney.d(varargin{:});
        end
    end
    
end
