function disp(this)
% disp  Display method for model objects
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

STR_VARIANT = 'Parameter Variant';
CONFIG = iris.get( );

%--------------------------------------------------------------------------

isEmpty = isempty(this.Variant.Values);

if this.IsLinear
    attribute = 'Linear';
else
    attribute = 'Nonlinear';
end

ccn = getClickableClassName(this);

if isEmpty
    fprintf(CONFIG.DispIndent);
    fprintf('Empty %s %s Object\n', attribute, ccn);    
else
    nv = length(this);
    fprintf(CONFIG.DispIndent);
    fprintf( '%s %s Object: [%g %s(s)]\n', ...
             attribute, ccn, nv, STR_VARIANT );
    
end

implementDisp(this.Equation);

if isEmpty
    % Print nothing
else
    printSolution( );
end

disp@shared.CommentContainer(this, 1);
disp@shared.UserDataContainer(this, 1);
implementDisp(this.Export);
textual.looseLine( );

return
    

    function printSolution( )
        [~, ix] = isnan(this, 'Solution');
        numOfSolutions = nnz(~ix);
        fprintf(CONFIG.DispIndent);
        fprintf( 'Solution(s) Available: [%g %s(s)]\n', ...
                 numOfSolutions, STR_VARIANT );
    end%
end%

