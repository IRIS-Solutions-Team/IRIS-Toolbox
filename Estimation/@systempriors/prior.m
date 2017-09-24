function this = prior(this, def, priorFunc, varargin)
% prior  Add new prior to system priors object.
%
%
% __Syntax__
%
%     S = prior(S, Expr, PriorFn, ...)
%     S = prior(S, Expr, [ ], ...)
%
%
% __Input Arguments__
%
% * `S` [ systempriors ] - System priors object.
%
% * `Expr` [ char ] - Expression that defines a value for which a prior
% density will be defined; see Description for system properties that can
% be referred to in the expression.
%
% * `PriorFn` [ function_handle | empty ] - Function handle returning the
% log of prior density; empty prior function, `[ ]`, means a uniform prior.
%
%
% __Output Arguments__
%
% * `S` [ systempriors ] - The system priors object with the new prior
% added.
%
% __Options__
%
% * `'LowerBound='` [ numeric | *`-Inf`* ] - Lower bound for the prior.
%
% * `'UpperBound='` [ numeric | *`Inf`* ] - Upper bound for the prior.
%
%
% __Description__
%
% _System Properties That Can Be Used in `Expr`_
%
% * `srf[VarName, ShockName, T]` - Plain shock response function of variables
% `VarName` to shock `ShockName` in period `T`. Mind the square brackets.
%
% * `ffrf[VarName, MVarName, Freq]` - Filter frequency response function of
% transition variables `TVarName` to measurement variable `MVarName` at
% frequency `Freq`. Mind the square brackets.
%
% * `corr[VarName1, VarName2, Lag]` - Correlation between variable
% `VarName1` and variables `VarName2` lagged by `Lag` periods.
%
% * `spd[VarName1, VarName2, Freq]` - Spectral density between
% variables `VarName1` and `VarName2` at frequency `Freq`.
%
% If a variable is declared as a [`log variable`](modellang/logvariables), 
% it must be referred to as `log(VarName)` in the above expressions, and
% the log of that variables is returned, e.g.
% `srf[log(VarName), ShockName, T]`. or `ffrf[log(TVarName), MVarName, T]`.
%
%
% _Expressions Involving Combinations or Functions of Parameters_
%
% Model parameter names can be referred to in `Expr` preceded by a dot
% (period), e.g. `.alpha^2 + .beta^2` defines a prior on the sum of squares
% of the two parameters (`alpha` and `beta`).
%
%
% __Example__
%
% Create a new empty systemprios object based on an existing model.
%
%     s = systempriors(m);
%
% Add a prior on minus the shock response function of variable `ygap` to
% shock `eps` in period 4. The prior density is lognormal with mean 0.3 and
% std deviation 0.05;
%
%     s = prior(s, '-srf[ygap, eps, 4]', logdist.lognormal(0.3, 0.05));
%
% Add a prior on the gain of the frequency response function of transition
% variable `ygap` to measurement variable 'y' at frequency `2*pi/40`. The
% prior density is normal with mean 0.5 and std deviation 0.01. This prior
% says that we wish to keep the cut-off periodicity for trend-cycle
% decomposition close to 40 periods.
%
%     s = prior(s, 'abs(ffrf[ygap, y, 2*pi/40])', logdist.normal(0.5, 0.01));
%
% Add a prior on the sum of parameters `alpha1` and `alpha2`. The prior is
% normal with mean 0.9 and std deviation 0.1, but the sum is forced to be
% between 0 and 1 by imposing lower and upper bounds.
%
%     s = prior(s, '.alpha1 + .alpha2', logdist.normal(0.9, 0.1), ...
%         'lowerBound=', 0, 'upperBound=', 1);
%
% Add a prior saying that the first 16 periods account for at least 90% of
% total variability (cyclicality) in a 40-period response of `ygap` to
% shock `eps`. This prior is meant to suppress secondary cycles in shock
% response functions.
%
%     s = prior(s, ...
%        'sum(abs(srf[ygap, eps, 1:16])) / sum(abs(srf[ygap, eps, 1:40]))', ...
%        [ ], 'lowerBound=', 0.9);
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

persistent INPUT_PARSER
if isempty(INPUT_PARSER)
    INPUT_PARSER = extend.InputParser('systempriors/prior');
    INPUT_PARSER.addRequired('SystemPriors', @(x) isa(x, 'systempriors'));
    INPUT_PARSER.addRequired('Definition', @(x) ischar(x) || (isa(x, 'string') && numel(x)==1));
    INPUT_PARSER.addRequired('PriorFunc', @(x) isempty(x) || isa(x, 'function_handle'));
    INPUT_PARSER.addParameter('LowerBound', -Inf, @(x) isnumeric(x) && numel(x)==1 && imag(x)==0);
    INPUT_PARSER.addParameter('UpperBound', Inf, @(x) isnumeric(x) && numel(x)==1 && imag(x)==0);
end
INPUT_PARSER.parse(this, def, priorFunc, varargin{:});
opt = INPUT_PARSER.Options;

%--------------------------------------------------------------------------

% Remove all blank space; this may not be, in theory, proper as the user
% moight have specified a string with blank spaces inside the definition
% string, but this case is quite unlikely, and we make sure to explain this
% in the help.
def = regexprep(def, '\s+', '');
inpDef = def;

% Parse system function names.
[this, def] = parseSystemFunctions(this, def);

% Parse references to parameters and steady-state values of variables.
def = parseNames(this, def);

try
    this.Eval{end+1} = str2func( ...
        ['@(srf, ffrf, cov, corr, pws, spd, Quantity, StdCorr) ', def] ...
        );
catch %#ok<CTCH>
    throw( ...
        exception.Base('SystemPriors:ERROR_PARSING_DEFINITION', 'error'), ...
        inpDef ...
    );
end
this.PriorFn{end+1} = priorFunc;
this.UserString{end+1} = inpDef;
this.Bounds(:, end+1) = [opt.LowerBound; opt.UpperBound];
end


function [this, def] = parseSystemFunctions(this, def)
    % Replace variable names in the system function definition `Def`
    % with the positions in the respective matrices (the positions are
    % function-specific), and update the (i) number of simulated periods, (ii)
    % FFRF frequencies, (iii) ACF lags, and (iv) XSF frequencies that need to be
    % computed.
    listOfSystemFunctions = fieldnames(this.SystemFn);
    ptn = sprintf('%s|', listOfSystemFunctions{:});
    ptn = ['\<(', ptn(1:end-1), ')[\(\[]'];
    previousEnd = 0;
    while true
        % System function names `srf`, `ffrf`, `cov`, `corr`, `pws`, 
        % `spd` are case insensitive.
        [start, open] = regexpi(def(previousEnd+1:end), ptn, 'start', 'end', 'once');
        if isempty(open)
            break
        end
        start = start + previousEnd;
        open = open + previousEnd;
        close = textfun.matchbrk(def, open);
        if isempty(close)
            throw( ...
                exception.Base('SystemPriors:ERROR_PARSING_DEFINITION', 'error'), ...
                def(start:end) ...
            );
        end
        funcName = def(start:open-1);
        funcName = lower(funcName);
        funcArgs = def(open+1:close-1);
        if ~isfield(this.SystemFn, funcName)
            throw( ...
                exception.Base('SystemPriors:INVALID_PRIOR_FUNCTION', 'error'), ...
                funcName ...
            );
        end
        [this, rpl, isError] = replaceSystemFunc(this, funcName, funcArgs);
        if isError
            throw( ...
                exception.Base('SystemPriors:ERROR_PARSING_DEFINITION', 'error'), ...
                def(start:close) ...
            );
        end
        def = [def(1:start-1), rpl, def(close+1:end)];
        previousEnd = close;
    end
end


function [this, c, isErr] = replaceSystemFunc(this, funcName, argStr)
    c = '';
    isErr = false;

    % Retrieve the system function struct for convenience.
    s = this.SystemFn.(funcName);

    tok = regexp(argStr, '(.*?),(.*?),(.*)', 'once', 'tokens');
    if isempty(tok)
        tok = regexp(argStr, '(.*?),(.*?)', 'once', 'tokens');
        if ~isempty(tok)
            tok{end+1} = s.defaultPageStr;
        end
    end
    if length(tok)~=3
        isErr = true;
        return
    end

    rowName = tok{1};
    colName = tok{2};
    % `page` can be a scalar or a vector of pages.
    page = eval(tok{3});
    if ~all(isfinite(page)) || ~s.validatePage(page)
        isErr = true;
        return
    end

    posRow = find( strcmp(rowName, s.rowName) );
    posCol = find( strcmp(colName, s.colName) );
    chkRowColNames( );

    try 
        % Add all pages requested by the user.
        pagePosString = '';
        for iPage = page(:).'
            pagePos = find(s.page==iPage);
            if isempty(pagePos)
                addPage( );
            end
            if ~isempty(pagePosString)
                pagePosString = [pagePosString, ', ']; %#ok<AGROW>
            end
            pagePosString = [pagePosString, sprintf('%g', pagePos)]; %#ok<AGROW>
        end
        if length(page)~=1
            pagePosString = ['[', pagePosString, ']'];
        end
        
        c = sprintf('%s(%g, %g, %s)', funcName, posRow, posCol, pagePosString);
        
        % Update the system function struct.
        this.SystemFn.(funcName) = s; 
    catch %#ok<CTCH>
        isErr = true;
        return
    end

    return


    function addPage( )
        switch lower(funcName)
            case {'srf'}
                s.page = 1 : iPage;
                s.activeInput(posCol) = true;
            case {'cov', 'corr'}
                s.page = 0 : iPage;
                s.activeInput(posCol) = true;
                % Keep pages and active inputs for `cov` and `corr`
                % identical.
                this.SystemFn.cov.page = s.page;
                this.SystemFn.corr.page = s.page;
                this.SystemFn.cov.activeInput = s.activeInput;
                this.SystemFn.corr.activeInput = s.activeInput;
            case {'ffrf'}
                s.page(end+1) = iPage;
            case {'pws', 'spd'}
                s.page{end+1} = iPage;
                % Keep pages and active inputs for `pws` and `spd`
                % identical.
                this.SystemFn.pws.page = s.page;
                this.SystemFn.spd.page = s.page;
                this.SystemFn.pws.activeInput = s.activeInput;
                this.SystemFn.spd.activeInput = s.activeInput;
        end
        % Whatever the system function, the current page is now included
        % as the last one in the list of pages.
        pagePos = length(s.page);
    end


    function chkRowColNames( )
        if isempty(posRow)
            throw( ...
                exception.Base('SystemPriors:INVALID_ROW', 'error'), ...
                rowName ...
            );
        end
        if isempty(posCol)
            throw( ...
                exception.Base('SystemPriors:INVALID_COLUMN', 'error'), ...
                colName ...
            );
        end        
    end
end


function def = parseNames(this, def)
    % Parse references to parameters and steady-state values of variables.

    lsInvalid = { };

    % Dot-references to the names of variables, shocks and parameters names
    % (must not be followed by an opening round bracket).
    ptn = '\.(\<[a-zA-Z]\w*\>(?![\[\(]))';
    if true % ##### MOSW
        replaceFunc = @replace; %#ok<NASGU>
        def = regexprep(def, ptn, '${replaceFunc($1)}');
    else
        def = mosw.dregexprep(def, ptn, @replace, 1); %#ok<UNRCH>
    end

    if ~isempty(lsInvalid)
        throw( ...
            exception.Base('SystemPriors:INVALID_NAME', 'error'), ...
            lsInvalid{:} ...
        );
    end

    return


    function c1 = replace(c0)
        c1 = '';
        ell = lookup(this.Quantity, {c0});
        posName = ell.PosName;
        posStdCorr = ell.PosStdCorr;
        if ~isnan(ell.PosName)
            c1 = sprintf('Quantity(1, %g)', ell.PosName);
        elseif ~isnan(ell.PosStdCorr)
            c1 = sprintf('StdCorr(1, %g)', ell.PosStdCorr);
        else
            lsInvalid{end+1} = c0;
        end
    end
end
