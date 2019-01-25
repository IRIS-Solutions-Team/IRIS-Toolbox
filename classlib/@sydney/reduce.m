function this = reduce(this, varargin)
% reduce  Reduce algebraic expressions if possible.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2019 IRIS Solutions Team.

persistent SYDNEY;
if isnumeric(SYDNEY)
    SYDNEY = sydney( );
end

% @@@@@ MOSW
template = SYDNEY;

%--------------------------------------------------------------------------

% This.lookahead = [ ];
nArg = length(this.args);

if isempty(this.Func)
    if isnumeric(this.args)
        % This is a number. Do nothing.
        return
    elseif islogical(this.args)
        % This is a logical index indicating a particular derivative among
        % multiple derivatives. You cannot run reduce without the second
        % input argument in that case.
        if isempty(varargin)
            this.args = double(this.args);
            return
        end
        k = varargin{1};
        if k==find(this.args)
            this.Func = '';
            this.args = 1;
        else
            this.Func = '';
            this.args = 0;
        end
        return
    elseif ischar(this.args)
        % This is a variable name. Do nothing.
        return
    else
        utils.error('sydney', ...
            'Cannot run reduction before differentation.');
    end
end

% Reduce all arguments first.
for i = 1 : length(this.args)
    this.args{i} = reduce(this.args{i}, varargin{:});
end

if strcmp(this.Func, 'sydney.d')
    % This is diff of an external function.
    return
end

% {
% Reduce a*(x/a), (x/a)*a to x.
if strcmp(this.Func, 'times');
    cancelTimes( );
end
% }

% {
% Reduce a/(x*a), a/(a*x) to 1/x, (x*a)/a, (a*x)/a to x.
if strcmp(this.Func, 'rdivide')
    cancelRdivide( );
end
% }

% Evaluate the function if all arguments are numeric.
if ~isempty(this.Func) && iscell(this.args) && ~isempty(this.args)
    isAllNumeric = true;
    args = cell(1,nArg);
    for i = 1 : nArg
        isAllNumeric = isAllNumeric && isnumeric(this.args{i}.args);
        if ~isAllNumeric
            break
        end
        args{i} = this.args{i}.args;
    end
    if isAllNumeric
        % Evaluate multiple plus; the arguments are guaranteed to be the same size
        % at this point.
        if strcmp(this.Func, 'plus')
            try
                x = sum([args{:}], 2);
            catch
                x = args{1};
                for i = 2 : length(args)
                    x = x + args{i};
                end
            end
            this.Func = '';
            this.args = x;
            return
        else
            try
                this.args = builtin(this.Func, args{:});
                this.Func = '';
                return
            catch %#ok<CTCH>
                try
                    this.args = feval(this.Func, args{:});
                    this.Func = '';
                    return
                catch
                    utils.error('sydney:reduce', ...
                        ['Cannot evaluate numerical component ', ...
                        'of sydney expression.']);
                end
            end
        end
    end
end

switch this.Func
    case 'uplus'
        reduceUplus( );
    case 'uminus'
        reduceUminus( );
    case 'plus'
        reducePlus( );
    case 'minus'
        reduceMinus( );
    case 'times'
        reduceTimes( );
    case 'rdivide'
        reduceRdivide( );
    case 'power'
        reducePower( );
    case 'exp'
        cancelExpLog( );
    case 'log'
        cancelLogExp( );
end

% Convert nested plus to multiple plus.
if strcmp(this.Func, 'plus')
    args = { };
    nArg = length(this.args);
    for iArg = 1 : nArg
        if strcmp(this.args{iArg}.Func, 'plus')
            args = [args, this.args{iArg}.args]; %#ok<AGROW>
        else
            args = [args, this.args(iArg)]; %#ok<AGROW>
        end
    end
    this.args = args;
end

return




    function reduceUplus( )
        if isequal(this.args{1}.args, 0)
            this.Func = '';
            this.args = 0;
        elseif isnumeric(this.args{1}.args)
            this.Func = '';
            this.args = this.args{1}.args;
        end
    end




    function reduceUminus( )
        if isequal(this.args{1}.args, 0)
            this.Func = '';
            this.args = 0;
        elseif isnumeric(this.args{1}.args)
            this.Func = '';
            this.args = -this.args{1}.args;
        end
    end




    function reducePlus( )
        nnArg = length(this.args);
        keep = true(1, nnArg);
        for iiArg = 1 : nnArg
            keep(iiArg) = ~isequal(this.args{iiArg}.args, 0);
        end
        if sum(keep) == 1
            this = this.args{keep};
        else
            this.args(~keep) = [ ];
        end
    end




    function reduceMinus( )
        if isequal(this.args{1}.args, 0)
            this.Func = 'uminus';
            this.args = this.args(2);
        elseif isequal(this.args{2}.args, 0)
            this = this.args{1};
        end
    end




    function reduceTimes( )
        isWrap = isUminusWrapper( );
        if isequal(this.args{1}.args, 0) || isequal(this.args{2}.args, 0)
            % 0*x or x*0
            this.Func = '';
            this.args = 0;
            return
        end
        if isequal(this.args{1}.args, 1)
            % 1*x.
            this = this.args{2};
        elseif isequal(this.args{2}.args, 1)
            % x*1.
            this = this.args{1};
        elseif isequal(this.args{1}.args, -1)
            % (-1)*x.
            this.Func = 'uminus';
            this.args = this.args(2);
        elseif isequal(this.args{2}.args, -1)
            % x*(-1).
            this.Func = 'uminus';
            this.args = this.args(1);
        end
        if isWrap
            x = this;
            this = template;
            this.Func = 'uminus';
            this.args = { x };
        end
    end




    function reduceRdivide( )
        isWrap = isUminusWrapper( );
        if isequal(this.args{1}.args, 0)
            % 0/x.
            this.Func = '';
            this.args = 0;
            return
        elseif isequal(this.args{2}.args, 1)
            % x/1.
            this = this.args{1};
        end
        if isWrap
            x = this;
            this = template;
            this.Func = 'uminus';
            this.args = { x };
        end
    end




    function reducePower( )
        if isequal(this.args{2}.args, 0) || isequal(this.args{1}.args, 1)
            % x^0 or 1^x.
            this.Func = '';
            this.args = 1;
%         elseif isequal(This.args{1}.args, 0)
%             % 0^x but not 0^0 (caught in the block).
%             This.Func = '';
%             This.args = 0;
        elseif isequal(this.args{2}.args, 1)
            % x^1.
            this = this.args{1};
        end
    end




    function isWrapUminus = isUminusWrapper( )
        % Count the uminus and negative numeric arguments. If there is at least
        % one, remove every uminus and convert negatives into positives. If the
        % total of occurences is an even number, we're done. If the total of
        % occurences is odd, wrap the final result in uminus.
        isWrapUminus = false;
        nnArg = length(this.args);
        isUminus = false(1, nnArg);
        for ii = 1 : nnArg
            a = this.args{ii};
            isUminus(ii) = isequal(a.Func, 'uminus') ...
                || (isnumeric(a.args) && all(a.args<0));
        end
        if any(isUminus)
            for ii = find(isUminus)
                if isnumeric(this.args{ii}.args)
                    this.args{ii}.args = -this.args{ii}.args;
                else
                    this.args{ii} = this.args{ii}.args{1};
                end
            end
            nu = sum(isUminus);
            isWrapUminus = nu/2~=round(nu/2);
        end
    end




    function cancelTimes( )
        if isequal(this.args{2}.Func, 'rdivide')
            % Reduce a*(x/a) to x.
            if isequal(this.args{1},this.args{2}.args{2})
                this = this.args{2}.args{1};
            end
        elseif isequal(this.args{1}.Func, 'rdivide')
            % Reduce (x/a)*a to x.
            if isequal(this.args{2},this.args{1}.args{2})
                this = this.args{1}.args{1};
            end
        end
    end




    function cancelRdivide( )
        if isequal(this.args{2}.Func, 'times')
            if isequal(this.args{1},this.args{2}.args{1})
                % Reduce a/(a*x) to 1/x.
                z1 = template;
                z1.args = 1;
                z1.lookahead = false;
                z2 = this.args{2}.args{2};
                this = template;
                this.Func = 'rdivide';
                this.args = {z1,z2};
                this.lookahead = [false, any(z2.lookahead)];
            elseif isequal(this.args{1}, this.args{2}.args{2})
                % Reduce a/(x*a) to 1/x.
                z1 = template;
                z1.args = 1;
                z1.lookahead = false;
                z2 = this.args{2}.args{1};
                this = template;
                this.Func = 'rdivide';
                this.args = {z1, z2};
                this.lookahead = [false, any(z2.lookahead)];
            end
        elseif isequal(this.args{1}.Func, 'times')
            if isequal(this.args{2}, this.args{1}.args{2})
                % Reduce (x*a)/a to x.
                this = this.args{1}.args{1};
            elseif isequal(this.args{2}, this.args{1}.args{1})
                % Reduce (a*x)/a to x.
                this = this.args{1}.args{2};
            end
        end
    end




    function cancelLogExp( )
        if isequal(this.args{1}.Func, 'exp')
            this = this.args{1}.args{1};
        end
    end




    function cancelExpLog( )
        if isequal(this.args{1}.Func, 'log')
            this = this.args{1}.args{1};
        end
    end
end
