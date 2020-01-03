function equation = postparse(equation, quantity)
% postparse  Postparse model equations.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2020 IRIS Solutions Team.

TYPE = @int8;
NAME_PATTERN = '(?<!\.)\<([A-Za-z]\w*)\>(?![\.\(])';
NAME_REPLACE = '${FN_GET_RPL($1, $`)}';

%--------------------------------------------------------------------------

numEqtn = length(equation);
inxm = equation.Type==TYPE(1);
inxt = equation.Type==TYPE(2);
inxl = equation.Type==TYPE(4);
inxmt = inxm | inxt;
inxNonemptySteady = inxmt & ~cellfun(@isempty, equation.Steady);

% Names of std_ and corr_ can be used only in dynamic links.
lsStdCorr = cell(1, 0);
if any(inxl)
    lsStdCorr = regexp(equation.Dynamic(inxl), '(std_|corr_)\w+', 'match');
    lsStdCorr = [ lsStdCorr{:} ];
    lsStdCorr = unique(lsStdCorr);
end

% Create lists of replacements
[rpl, rplSx] = pattern4postparse(quantity, lsStdCorr);

d = cell2struct(rpl, quantity.Name, 2);
FN_GET_RPL = @getRpl; %#ok<NASGU>
listUndeclaredName = cell(1, 0);
listUndeclaredEqtn = cell(1, 0);
inxUndeclaredStdCorr = false(1, 0);

id = cellfun( @(x) sprintf('#%g#', x), num2cell(1:numEqtn), 'UniformOutput', false);
equation.Dynamic = strcat(id, equation.Dynamic);
equation.Steady = strcat(id, equation.Steady);

%
% Dynamic equations except dtrends and links
%
isl = false;
equation.Dynamic(~inxl) = regexprep( ...
    equation.Dynamic(~inxl), ...
    NAME_PATTERN, ...
    NAME_REPLACE ...
);

%
% Steady equations
%
if any(inxNonemptySteady)
    isl = false;
    equation.Steady(inxNonemptySteady) = regexprep( ...
        equation.Steady(inxNonemptySteady), ...
        NAME_PATTERN, ...
        NAME_REPLACE ...
    );
end

%
% Dynamic links
%
if any(inxl)
    d = cell2struct([rpl, rplSx], [quantity.Name, lsStdCorr], 2);
    isl = true;
    equation.Dynamic(inxl) = regexprep( ...
        equation.Dynamic(inxl), ...
        NAME_PATTERN, ...
        NAME_REPLACE ...
    );
end

if ~isempty(listUndeclaredName)
    hereReportUndeclared( );
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
inxNonemptySteady = cellfun(@isempty, equation.Steady);
inxCopy = false(1, numEqtn);
for i = find(inxNonemptySteady & inxmt)
    inxCopy(i) = ~isempty( strfind(equation.Dynamic{i}, '&x(') );
end
equation.Steady(inxCopy) = equation.Dynamic(inxCopy);

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
            listUndeclaredName{end+1} = name;
            iEq = regexp(pre, '^#\d+#', 'match', 'once');
            iEq = str2double(iEq(2:end-1));
            listUndeclaredEqtn{end+1} = equation.Input{iEq};
            inxUndeclaredStdCorr(end+1) = ~isl && ...
                ( strncmp(name, 'std_', 4) || strncmp(name, 'corr_', 5) );
            c = '';
        end
    end




    function hereReportUndeclared( )
        % Get unique name-eqtn pairs.
        [~, inxUnique] = unique( strcat(listUndeclaredName, listUndeclaredEqtn) );
        listUndeclaredName = listUndeclaredName(inxUnique);
        listUndeclaredEqtn = listUndeclaredEqtn(inxUnique);
        inxUndeclaredStdCorr = inxUndeclaredStdCorr(inxUnique);
        
        % Report std or corr names used in equations other than links.
        if any(inxUndeclaredStdCorr)
            n = sum(inxUndeclaredStdCorr);
            rpt = cell(1, 2*n);
            rpt(1:2:end) = listUndeclaredName(inxUndeclaredStdCorr);
            rpt(2:2:end) = listUndeclaredEqtn(inxUndeclaredStdCorr);
            throw( ...
                exception.Base('Equation:STD_CORR_IN_OTHER_THAN_LINK', 'error'), ...
                rpt{:} ...
            );
        end
        
        % Report non-function names that have not been declared.
        if any(~inxUndeclaredStdCorr)
            n = sum(~inxUndeclaredStdCorr);
            rpt = cell(1, 2*n);
            rpt(1:2:end) = listUndeclaredName(~inxUndeclaredStdCorr);
            rpt(2:2:end) = listUndeclaredEqtn(~inxUndeclaredStdCorr);            
            throw( ...
                exception.Base('Equation:UNDECLARED_MISTYPED_NAME', 'error'), ...
                rpt{:} ...
            );
        end        
    end
end
