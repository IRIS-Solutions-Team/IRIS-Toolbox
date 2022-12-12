% instrument  Define forecast conditioning instruments in VAR models.
%
% Syntax to add forecast instruments
% ===================================
%
%     V = instrument(V, Def)
%     V = instrument(V, Name, Expr)
%     V = instrument(V, Name, Vec)
%
%
% Syntax to remove all forecast instruments
% ==========================================
%
%     V = instrument(V)
%
%
% Input arguments
% ================
%
% * `V` [ VAR ] - VAR object to which forecast instruments will be added.
%
% * `Def` [ char | cellstr ] - Definition of the new forecast conditioning
% instrument.
%
% * `Name` [ char ] - Name of the new forecast conditiong instrument.
%
% * `Expr` [ char ] - Expression defining the new forecast conditiong
% instrument.
%
% * `Vec` [ numeric ] - Vector of coeffients to combine the VAR variables
% to create the new forecast conditioning instrument.
%
%
% Output arguments
% =================
%
% * `V` [ VAR ] - VAR object with forecast instruments added or removed.
%
%
% Description
% ============
%
% Conditioning instruments allow you to compute forecasts conditional upon
% a linear combinationi of endogenous variables.
%
% The definition strings must have the following form:
%
%     'name := expression'
%
% where `name` is the name of the new conditioning instrument, and
% `expression` is an expression referring to existing VAR variable names
% and/or their lags.
%
% Alternatively, you can separate the name and the expression into two
% input arguments. Or you can define the instrument by a vector of
% coefficients, either `1`-by-`N` or `1`-by-`(N+1)`, where `N` is the
% number of variables in the VAR object `V`, and the last optional element
% is a constant term (set to zero if no value supplied).
%
% The conditioning instruments must be a linear combination (possibly with
% a constant) of the existing endogenous variables and their lags up to p-1
% where p is the order of the VAR. The names of the conditioning
% instruments must be unique (i.e. distinct from the names of endogenous
% variables, residuals, exogenous variables, and existing instruments).
%
%
% Example
% ========
%
% In the following example, we assume that the VAR object `v` has at least
% three endogenous variables named `x`, `y`, and `z`.
%
%     V = instrument(V, 'i1 := x - x{-1}', 'i2: = (x + y + z)/3');
%
% Note that the above line of code is equivalent to
%
%     V = instrument(V, 'i1 := x - x{-1}');
%     V = instrument(V, 'i2: = (x + y + z)/3');
%
% The command defines two conditioning instruments named `i1` and `i2`. The
% first instrument is the first difference of the variable `x`. The second
% instrument is the average of the three endogenous variables.
%
% To impose conditions (tunes) on a forecast using these instruments, you
% run [`VAR/forecast`](VAR/forecast) with the fourth input argument
% containing a time series for `i1`, `i2`, or both.
%
%     j = struct( );
%     j.i1 = Series(startdate:startdate+3, 0);
%     j.i2 = Series(startdate:startdate+3, [1;1.5;2]);
%
%     f = forecast(v, d, startdate:startdate+12, j);
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

function this = addInstrument(this, name, def)

    numY = this.NumEndogenous;
    p = this.Order;

    if ischar(def) || isstring(def)
        vector = here_createVector();
        [Z, C, isValid] = parser.vectorizeLinComb(def, vector);
        if any(~isValid) || C~=0
            exception.error([
                "VAR"
                "This is not a valid conditioning instrument definition: %s"
            ], def);
        end
    else
        def = reshape(def, 1, []);
        if numel(def)==numY
            Z = def;
            C = 0;
        elseif numel(def)==p*numY+1
            Z = def(1:end-1);
            C = def(end);
        else
            exception.error([
                "VAR"
                "Incorrect size of conditioning instrument definition vector."
            ]);
        end
    end

    this.ConditioningNames = [this.ConditioningNames, name];
    this.Zi = [this.Zi; [C, Z]];

return

    function vector = here_createVector()
        vector = this.EndogenousNames;
        for ii = 1 : p-1
            sh = sprintf("{-%g}", ii);
            vector = [vector, this.EndogenousNames+sh]; %#ok<AGROW>
        end
    end%

end%
