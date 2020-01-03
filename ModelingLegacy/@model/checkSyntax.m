function checkSyntax(this, qty, eqn)
% checkSyntax  Check equations for syntax errors
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 IRIS Solutions Team

TYPE = @int8;

%--------------------------------------------------------------------------

numQuan = length(qty);
sh0 = this.Incidence.Dynamic.PosOfZeroShift;
nsh = this.Incidence.Dynamic.NumOfShifts;
ne = sum(qty.Type==TYPE(31) | qty.Type==TYPE(32));
ixl = eqn.Type==TYPE(4);
inxYX = getIndexByType(qty, TYPE(1), TYPE(2));

x = rand(numQuan, nsh);
L = x;
% L = x(inxYX, :);

% Create a random vector `x` for dynamic links. In dynamic links, we allow
% std and corr names to occurs, and append them to the assign vector.
if any(ixl)
    if this.IsLinear
        std = this.DEFAULT_STD_LINEAR;
    else
        std = this.DEFAULT_STD_NONLINEAR;
    end
    xLink = [ rand(numQuan, 1); std*ones(ne, 1); zeros(ne*(ne-1)/2, 1) ];
end

% Dynamic equations
try
    fn = [ '@(x,t,L) [', eqn.Dynamic{~ixl}, ']' ];
    if true % ##### MOSW
        fn = str2func(fn);
    else
        fn = mosw.str2func(fn); %#ok<UNRCH>
    end
    feval(fn, x, sh0, L);
catch
    lookup(eqn.Dynamic, ~ixl);
end

% Steady equations.
fn = [ '@(x,t,L) [', eqn.Steady{~ixl}, ']' ];
try
    if true % ##### MOSW
        fn = str2func(fn);
    else
        fn = mosw.str2func(fn); %#ok<UNRCH>
    end
    feval(fn, x, sh0, L);
catch
    lookup(eqn.Steady, ~ixl);
end

% Dynamic links.
if any(ixl)
  try
        fn = [ '@(x,t,L) [', eqn.Dynamic{ixl}, ']' ];
        if true % ##### MOSW
            fn = str2func(fn);
        else
            fn = mosw.str2func(fn); %#ok<UNRCH>
        end
        feval(fn, xLink, 1, [ ]);
  catch
       lookup(eqn.Dynamic, ixl);
   end
end

return




    function lookup(lsEqn, ix)
        errUndeclared = { };
        errSyntax = { };
        
        for iiEq = find(ix)
            if isempty(lsEqn{iiEq})
                continue
            end
            fn = lsEqn{iiEq};
            try
                fn = vectorize(fn);
                fn = ['@(x,t,L)', fn]; %#ok<AGROW>
                fn = str2func(fn);
                
                if eqn.Type(iiEq)~=TYPE(4)
                    feval(fn, x, sh0, L);
                else
                    % Evaluate RHS of dynamic links. They can refer to std or corr names, so we
                    % have to use the `x1` vector.
                    feval(fn, xLink, 1, [ ]);
                end            
            catch E
                % Undeclared names should have been already caught. But a few exceptions
                % may still exist.
                [mtc, tkn] = ...
                    regexp(E.message, ...
                    'Undefined function or variable ''(\w*)''', ...
                    'match','tokens','once');
                if ~isempty(mtc)
                    errUndeclared{end+1} = tkn{1}; %#ok<AGROW>
                    errUndeclared{end+1} = eqn.Input{iiEq}; %#ok<AGROW>
                else
                    message = E.message;
                    errSyntax{end+1} = eqn.Input{iiEq}; %#ok<AGROW>
                    if ~isempty(message) && message(end) ~= '.'
                        message(end+1) = '.'; %#ok<AGROW>
                    end
                    errSyntax{end+1} = message; %#ok<AGROW>
                end
            end
            
        end
        
        if ~isempty(errUndeclared)
            throw( exception.ParseTime('Equation:UndeclaredMistypedName', 'error'), ...
                   errUndeclared{:} );
        end
        
        if ~isempty(errSyntax)
            throw( exception.ParseTime('Model:Postparser:SyntaxError', 'error'), ...
                   errSyntax{:} );
        end
    end
end
