function this = parseExpression(this, regression, expression)

expression0 = string(expression);
expression = char(expression);
expression = strrep(expression, ' ', '');

%
% Expand pseudofunctions
% diff, difflog, dot, movsum, movavg, movprod, movgeom
%
expression = parser.Pseudofunc.parse(expression);

%
% Replace name{k} with x(pos, t+k, :)
% Replace name with x(pos, t, :)
%
positions = double.empty(1, 0);
shifts = 0;
invalidNames = string.empty(1, 0);
invalidShifts = string.empty(1, 0);
replaceFunc = @replaceNameShift;
expression = regexprep(expression, '(\<[A-Za-z]\w*\>)(\{[^\}]*\})', '${replaceFunc($1, $2)}');
expression = regexprep(expression, '(\<[A-Za-z]\w*\>)(?!\()', '${replaceFunc($1)}');
expression = strrep(expression, '$', 't');

%
% Vectorize operators
%
expression = vectorize(expression);

%
% Create anonymous function
%
try
    this.Expression = str2func(['@(x, t) ', expression]);
catch
    hereThrowInvalidSpecification( );
end


this.Position = positions;
this.MinShift = min(shifts);
this.MaxShift = max(shifts);

return


    function c = replaceNameShift(c1, c2)
        c = '';
        pos = getPositionOfName(regression, c1);
        if isnan(pos)
            invalidNames = [invalidNames, string(c1)];
            return
        end
        positions = [positions, pos];
        if nargin<2 || isempty(c2) || strcmp(c2, '{}')
            c = sprintf('x(%g, $, :)', pos);
            return
        end
        sh = str2num(c2(2:end-1));
        if ~validate.numericScalar(sh) || ~isfinite(sh)
            invalidShifts = [invalidShifts, string(c2)];
        end
        if sh ==0
            c = sprintf('x(%g, t, :)', pos);
            return
        else
            shifts = [shifts, sh];
            c = sprintf('x(%g, $%+g, :)', pos, sh);
            return
        end
    end%


    function hereThrowInvalidSpecification( )
        thisError = { 'Regression:InvalidTermSpecification'
                      'Invalid specification of a regression.Term: %s' };
        throw(exception.ParseTime(thisError, 'error'), expression0);
    end%
end%

