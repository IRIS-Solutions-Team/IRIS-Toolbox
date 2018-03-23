function equation = postparse(equation, quantity)
% postparse  Postparse model equations.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

TYPE = @int8;
NAME_PATTERN = '(?<!\.)\<([A-Za-z]\w*)\>(?![\.\(])';
NAME_REPLACE = '${FN_GET_RPL($1, $`)}';

%--------------------------------------------------------------------------

nEqtn = length(equation);
ixm = equation.Type==TYPE(1);
ixt = equation.Type==TYPE(2);
ixl = equation.Type==TYPE(4);
ixmt = ixm | ixt;
ixNonemptySteady = ixmt & ~cellfun(@isempty, equation.Steady);

% Names of std_ and corr_ can be used only in dynamic links.
lsStdCorr = cell(1, 0);
if any(ixl)
    lsStdCorr = regexp(equation.Dynamic(ixl), '(std_|corr_)\w+', 'match');
    lsStdCorr = [ lsStdCorr{:} ];
    lsStdCorr = unique(lsStdCorr);
end

% Create lists of replacements.
[rpl, rplSx] = pattern4postparse(quantity, lsStdCorr);

d = cell2struct(rpl, quantity.Name, 2);
FN_GET_RPL = @getRpl; %#ok<NASGU>
lsUndeclaredName = cell(1, 0);
lsUndeclaredEqtn = cell(1, 0);
ixUndeclaredStdCorr = false(1, 0);

id = cellfun( @(x) sprintf('#%g#', x), num2cell(1:nEqtn), 'UniformOutput', false);
equation.Dynamic = strcat(id, equation.Dynamic);
equation.Steady = strcat(id, equation.Steady);

% Dynamic equations except dtrends and links
%--------------------------------------------
isl = false;
equation.Dynamic(~ixl) = regexprep( ...
    equation.Dynamic(~ixl), ...
    NAME_PATTERN, ...
    NAME_REPLACE ...
    );

% Steady equations
%------------------
if any(ixNonemptySteady)
    isl = false;
    equation.Steady(ixNonemptySteady) = regexprep( ...
        equation.Steady(ixNonemptySteady), ...
        NAME_PATTERN, ...
        NAME_REPLACE ...
        );
end

% Dynamic links
%---------------
if any(ixl)
    d = cell2struct([rpl, rplSx], [quantity.Name, lsStdCorr], 2);
    isl = true;
    equation.Dynamic(ixl) = regexprep( ...
        equation.Dynamic(ixl), ...
        NAME_PATTERN, ...
        NAME_REPLACE ...
        );
end

if ~isempty(lsUndeclaredName)
    reportUndeclared( );
end

equation.Dynamic = regexprep(equation.Dynamic, '^#\d+#', '');
equation.Steady = regexprep(equation.Steady, '^#\d+#', '');

% Finalize lags/leads x(10,t){@+2} -> x(10,t+2).
equation.Dynamic = strrep(equation.Dynamic, 't){@', 't');
equation.Dynamic = strrep(equation.Dynamic, '}', ')');
equation.Steady = strrep(equation.Steady, 't){@', 't');
equation.Steady = strrep(equation.Steady, '}', ')');

% Copy a dynamic equation into the respective empty steady equation if
% it contains a steady reference. Otherwise, only the dynamic equation will
% be maintained.
ixNonemptySteady = cellfun(@isempty, equation.Steady);
ixCopy = false(1, nEqtn);
for i = find(ixNonemptySteady & ixmt)
    ixCopy(i) = ~isempty( strfind(equation.Dynamic{i}, '&x(') );
end
equation.Steady(ixCopy) = equation.Dynamic(ixCopy);

% Replace steady-state references:
% * &x(...) -> L(...) in dynamic equations;
% * &x(...) -> x(...) in steady equations.
equation.Dynamic = strrep(equation.Dynamic, '&x(', 'L(');
equation.Steady = strrep(equation.Steady, '&x(', 'x(');

return




    function c = getRpl(name, pre)
        try
            c = d.(name);
        catch
            lsUndeclaredName{end+1} = name;
            iEq = regexp(pre, '^#\d+#', 'match', 'once');
            iEq = str2double(iEq(2:end-1));
            lsUndeclaredEqtn{end+1} = equation.Input{iEq};
            ixUndeclaredStdCorr(end+1) = ~isl && ...
                ( strncmp(name, 'std_', 4) || strncmp(name, 'corr_', 5) );
            c = '';
        end
    end




    function reportUndeclared( )
        % Get unique name-eqtn pairs.
        [~, ixUnique] = unique( strcat(lsUndeclaredName, lsUndeclaredEqtn) );
        lsUndeclaredName = lsUndeclaredName(ixUnique);
        lsUndeclaredEqtn = lsUndeclaredEqtn(ixUnique);
        ixUndeclaredStdCorr = ixUndeclaredStdCorr(ixUnique);
        
        % Report std or corr names used in equations other than links.
        if any(ixUndeclaredStdCorr)
            n = sum(ixUndeclaredStdCorr);
            rpt = cell(1, 2*n);
            rpt(1:2:end) = lsUndeclaredName(ixUndeclaredStdCorr);
            rpt(2:2:end) = lsUndeclaredEqtn(ixUndeclaredStdCorr);
            throw( ...
                exception.Base('Equation:STD_CORR_IN_OTHER_THAN_LINK', 'error'), ...
                rpt{:} ...
                );
        end
        
        % Report non-function names that have not been declared.
        if any(~ixUndeclaredStdCorr)
            n = sum(~ixUndeclaredStdCorr);
            rpt = cell(1, 2*n);
            rpt(1:2:end) = lsUndeclaredName(~ixUndeclaredStdCorr);
            rpt(2:2:end) = lsUndeclaredEqtn(~ixUndeclaredStdCorr);            
            throw( ...
                exception.Base('Equation:UNDECLARED_MISTYPED_NAME', 'error'), ...
                rpt{:} ...
                );
        end        
    end
end
