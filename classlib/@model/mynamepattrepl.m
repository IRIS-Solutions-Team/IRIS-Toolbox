function [ptn, rplDynamic, rtplSteady] = mynamepattrepl(this, quantity)
% mynamepattrepl  Patterns and replacements for names in equations.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

TYPE = @int8;

%--------------------------------------------------------------------------

nName = length(quantity.Name);
ptn = cell(1, nName);
rplDynamic = cell(1, nName);
rtplSteady = cell(1, nName);

ixg = quantity.Type==TYPE(5);
posg = find(ixg);

% Name patterns to search.
for i = 1 : nName
    ptn{i} = ['\<', quantity.Name{i}, '\>'];
    if quantity.Type(i)==TYPE(4)
        % Replace parameter names including steady-state references and time
        % subscripts; these are allowed but ignored.
        ptn{i} = [ '&?', ptn{i}, '((\{[^\}]+\})?)' ];
    end
end

% % ... variables, shocks, parameters
% @ ... time subscript
% ? ... exogenous variables
% ! ... name position

% Replacements in dynamic equations.
for i = 1 : nName
    switch quantity.Type(i)
        case {  TYPE(1), ...
                TYPE(2), ...
                TYPE(31), ...
                TYPE(32), ...
                TYPE(4) }
            % %(!5,@)
            ic = sprintf('%g', i);
            repl = [ '%(!', ic, ',@)' ];
        case TYPE(5)
            % ?(!15,:)
            j = find(i==posg, 1);
            ic = sprintf('%g', j);
            repl = [ '?(!', ic, ',:)' ];
        otherwise
            throw( exception.Base('General:INTERNAL', 'error') );
    end
    rplDynamic{i} = repl;
end

% Replacements in steady equations.
if ~this.IsLinear 
    for i = 1 : nName
        ic = sprintf('%g', i);
        switch quantity.Type(i)
            case { TYPE(1), ...
                   TYPE(2) };
                % %(!15)
                repl = [ '%(!', ic, ')' ];
            case {  TYPE(31), ...
                    TYPE(32) }
                repl = '0';
            case TYPE(4)
                % %(!15)
                repl = [ '%(!', ic, ')' ];
            case TYPE(5)
                % ?(!15)
                j = find(i==posg, 1);
                ic = sprintf('%g', j);
                repl = [ '?(!', ic, ')' ];
            otherwise
                throw( exception.Base('General:INTERNAL', 'error') );
        end
        rtplSteady{i} = repl;
    end
end

end
