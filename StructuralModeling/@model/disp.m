function disp(this)
% disp  Display method for model objects.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

STR_VARIANT = 'parameter variant';

%--------------------------------------------------------------------------

isEmpty = isempty(this.Variant);

if this.IsLinear
    attribute = 'linear';
else
    attribute = 'nonlinear';
end

ccn = getClickableClassName(this);

if isEmpty
    fprintf('\tempty %s %s object\n', attribute, ccn);    
else
    nAlt = length(this);
    fprintf('\t%s %s object: [%g %s(s)]\n', ...
        attribute, ccn, nAlt, STR_VARIANT);
    
end

implementDisp(this.Equation);

if isEmpty
    % Print nothing.
else
    printSolution( );
end

disp@shared.GetterSetter(this, 1);
disp@shared.UserDataContainer(this, 1);
disp(this.Export, 1);
textfun.loosespace( );

return


    

    function printSolution( )
        [~, ix] = isnan(this, 'solution');
        nSolution = sum(~ix);
        fprintf('\tsolution(s) available: [%g %s(s)]\n', ...
            nSolution, STR_VARIANT);
    end
end
