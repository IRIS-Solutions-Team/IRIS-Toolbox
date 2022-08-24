function checkSyntax(this, qty, eqn)

numQuan = length(qty);
sh0 = this.Incidence.Dynamic.PosZeroShift;
nsh = this.Incidence.Dynamic.NumShifts;
ne = sum(qty.Type==31 | qty.Type==32);
ixl = eqn.Type==4;
inxYX = getIndexByType(qty, 1, 2);

x = rand(numQuan, nsh);
L = x;
% L = x(inxYX, :);

% Create a random vector `x` for dynamic links. In dynamic links, we allow
% std and corr names to occurs, and append them to the assign vector.
if any(ixl)
    if this.LinearStatus
        std = this.DEFAULT_STD_LINEAR;
    else
        std = this.DEFAULT_STD_NONLINEAR;
    end
    xLink = [ rand(numQuan, 1); std*ones(ne, 1); zeros(ne*(ne-1)/2, 1) ];
end

% Dynamic equations
try
    fn = [ '@(x,t,L) [', eqn.Dynamic{~ixl}, ']' ];
    fn = str2func(fn);
    feval(fn, x, sh0, L);
catch
    lookup(eqn.Dynamic, ~ixl);
end

% Steady equations.
fn = [ '@(x,t,L) [', eqn.Steady{~ixl}, ']' ];
try
    fn = str2func(fn);
    feval(fn, x, sh0, L);
catch
    lookup(eqn.Steady, ~ixl);
end

% Dynamic links.
if any(ixl)
  try
        fn = [ '@(x,t,L) [', eqn.Dynamic{ixl}, ']' ];
        fn = str2func(fn);
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
                
                if eqn.Type(iiEq)~=4
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
