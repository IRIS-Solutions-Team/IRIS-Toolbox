function outputData = run(varargin)
% run  Evaluate reporting equations (rpteq) object
%
%
% __Syntax__
%
% Input arguments marked with a `~` sign may be omitted.
%
%     Outp = run(Q, Inp, Range, ~Model, ...)
%
%
% __Input arguments__
%
% * `Q` [ char ] - Reporting equations (rpteq) object.
%
% * `Inp` [ struct ] - Input database that will be used to evaluate the
% reporting equations.
%
% * `Dates` [ numeric | char ] - Dates at which the reporting equations
% will be evaluated; `Dates` does not need to be a continuous date range.
%
% * `~Model` [ model ] - Model object from which values will be substituted
% for steady-state references; if there are no steady-state references in
% reporting equations, this input argument may be omitted.
%
%
% __Output arguments__
%
% * `Outp` [ struct ] - Output database with reporting variables.
%
%
% __Options__
%
% * `'DbOverlay='` [ `true` | *`false`* | struct ] - If `true`, the LHS
% output data will be combined with data from the input database (or a
% user-supplied database).
%
% * `'Fresh='` [ `true` | *`false`* ] - If `true`, only the LHS reporting
% variables will be included in the output database, `Outp`; if `false` the
% output database will also include all entries from the input database, 
% `Inp`.
%
%
% __Description__
%
% Reporting equations are always evaluated non-simultaneously, i.e.
% equation by equation, for each period.
%
%
% __Example__
%
% Note the differences in the three output databases, `d1`, `d2`, `d3`, 
% depending on the options `AppendPresample=` and `Fresh=`.
%
%     >> q = rpteq({ ...
%         'a = c * a{-1}^0.8 * b{-1}^0.2;', ...
%         'b = sqrt(b{-1});', ...
%         })
% 
%     q =
%         rpteq object
%         number of equations: [2]
%         comment: ''
%         user data: empty
%         export files: [0]
%
%     >> d = struct( );
%     >> d.a = Series( );
%     >> d.b = Series( );
%     >> d.a(qq(2009, 4)) = 0.76;
%     >> d.b(qq(2009, 4)) = 0.88;
%     >> d.c = 10;
%     >> d
%
%     d = 
%         a: [1x1 tseries]
%         b: [1x1 tseries]
%         c: 10
%
%     >> d1 = run(q, d, qq(2010, 1):qq(2011, 4))
%
%     d1 = 
%         a: [8x1 tseries]
%         b: [8x1 tseries]
%         c: 10
%
%     >> d2 = run(q, d, qq(2010, 1):qq(2011, 4), 'AppendPresample=', true)
%
%     d2 = 
%         a: [9x1 tseries]
%         b: [9x1 tseries]
%         c: 10
%
%     >> d3 = run(q, d, qq(2010, 1):qq(2011, 4), 'Fresh=', true)
% 
%     d3 = 
%         a: [8x1 tseries]
%         b: [8x1 tseries]
% 

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 IRIS Solutions Team

TIME_SERIES_CONSTRUCTOR = iris.get('DefaultTimeSeriesConstructor');
TEMPLATE_SERIES = TIME_SERIES_CONSTRUCTOR( );

persistent parser
if isempty(parser)
    parser = extend.InputParser('rpteq.run');
    parser.addRequired('ReportingEquations', @(x) isa(x, 'rpteq'));
    parser.addRequired('InputData', @(x) isempty(x) || isstruct(x));
    parser.addRequired('SimulationDates', @(x) isa(x, 'DateWrapper') || isnumeric(x));
    parser.addOptional('Model', [ ], @(x) isempty(x) || isa(x, 'model'));
    parser.addParameter('AppendPresample', false, @(x) validate.logicalScalar(x) || isstruct(x));
    parser.addParameter('AppendPostsample', false, @(x) validate.logicalScalar(x) || isstruct(x));
    parser.addParameter('DbOverlay', false, @(x) validate.logicalScalar(x) || isstruct(x));
    parser.addParameter('Fresh', false, @validate.logicalScalar);
end
parse(parser, varargin{:});
this = parser.Results.ReportingEquations;
inputData = parser.Results.InputData;
dates = parser.Results.SimulationDates;
dates = double(dates);
m = parser.Results.Model;
opt = parser.Options;

%--------------------------------------------------------------------------

eqtn = this.EqtnRhs;
numOfEquations = numel(eqtn);
numOfRhsNames = numel(this.NamesOfRhs);
dates = dates(:).';
minDate = min(dates);
maxDate = max(dates);
maxSh = this.MaxSh;
minSh = this.MinSh;
extendedRange = minDate+minSh : maxDate+maxSh;
numExtendedPeriods = numel(extendedRange);
isSteadyRef = ~isempty(this.NamesOfSteadyRef) && isa(m, 'model');

D = struct( );
S = struct( );

% Convert tseries to arrays, remove time subscript placeholders # from
% non-tseries names. Pre-allocate LHS time series not supplied in input
% database.
checkRhsNames( );
preallocLhsNames( );
if isSteadyRef
    S = createSteadyRefDbase( );
end

eqtn = strrep(eqtn, '&?', 'S.');
eqtn = strrep(eqtn, '?', 'D.');
eqtn = regexprep(eqtn, '\{@(.*?)\}#', '(t$1, :)');
eqtn = strrep(eqtn, '#', '(t, :)');

fn = cell(1, numOfEquations);
for i = 1 : numOfEquations
    fn{i} = str2func(['@(D, t, S)', eqtn{i}]);
end

% Evaluate equations sequentially period by period
runTime = round(dates-minDate+1 - minSh);
for t = runTime
    for iEq = 1 : numOfEquations
        ithName = this.NamesOfLhs{iEq};
        lhs = D.(ithName);
        try
            x = fn{iEq}(D, t, S);
        catch %#ok<CTCH>
            x = NaN;
        end
        if size(x, 1)>1
            x = NaN;
        end
        x( isnan(x) ) = this.NaN(iEq);
        if length(x)>1 && ndims(lhs)==2 && size(lhs, 2)==1  %#ok<ISMAT>
            newSize = size(x);
            lhs = repmat(lhs, [1, newSize(2:end)]);
        end
        lhs(t, :) = x;
        D.(ithName) = lhs;
    end
end

outputData = struct( );
if ~opt.Fresh
    outputData = inputData;
end

for i = 1 : numOfEquations
    ithName = this.NamesOfLhs{i};
    data = D.(ithName)(-minSh+1:end-maxSh, :);
    ithComment = this.Label{i};
    outputData.(ithName) = fill(TEMPLATE_SERIES, data, minDate, ithComment);
end

outputData = appendData(this, inputData, outputData, [minDate, maxDate], opt);

return




    function s = createSteadyRefDbase( )
        ttrend = dat2ttrend(extendedRange, m);
        lsName = this.NamesOfSteadyRef;
        ell = lookup(m, this.NamesOfSteadyRef);
        pos = ell.PosName;
        ixNan = isnan(pos);
        if any(ixNan)
            throw( exception.Base('RptEq:STEADY_REF_NOT_FOUND_IN_MODEL', 'error'), ...
                lsName{ixNan} );
        end
        
        pos = pos(:).';
        X = createTrendArray(m, @all, true, pos, ttrend);
        X = permute(X, [2, 3, 1]);
        
        s = struct( );
        for ii = 1 : numel(lsName)
            iithName = lsName{ii};
            s.(iithName) = X(:, :, ii);
        end
    end%




    function checkRhsNames( )
        inxOfFound = true(1, numOfRhsNames);
        inxOfValid = true(1, numOfRhsNames);
        for ii = 1 : numOfRhsNames
            iithName = this.NamesOfRhs{ii};
            isField = isfield(inputData, iithName);
            inxOfFound(ii) = isField || any(strcmp(iithName, this.NamesOfLhs));
            if ~isField
                continue
            end
            if isa(inputData.(iithName), 'NumericTimeSubscriptable')
                D.(iithName) = rangedata(inputData.(iithName), extendedRange);
                continue
            end
            inxOfValid(ii) = isnumeric(inputData.(iithName)) && size(inputData.(iithName), 1)==1;
            if inxOfValid(ii)
                D.(iithName) = inputData.(iithName);
                eqtn = regexprep(eqtn, ['\?', iithName, '#'], ['?', iithName]);
            end
        end
        if any(~inxOfFound)
            throw( exception.Base('RptEq:RHS_NAME_DATA_NOT_FOUND', 'error'), ...
                this.NamesOfRhs{~inxOfFound} );
        end
        if any(~inxOfValid)
            throw( exception.Base('RptEq:RHS_NAME_DATA_INVALID', 'error'), ...
                this.NamesOfRhs{~inxOfFound} );
        end        
    end%




    function preallocLhsNames( )
        for ii = 1 : numOfEquations
            iithName = this.NamesOfLhs{ii};
            if ~isfield(D, iithName)
                D.(iithName) = nan(numExtendedPeriods, 1);
            end
        end
    end%
end%

