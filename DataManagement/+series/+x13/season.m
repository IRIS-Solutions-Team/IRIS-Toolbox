function varargout = season(data, startDate, varargin)

persistent pp
if isempty(pp)
    pp = extend.InputParser('series.x13.series');
    pp.KeepUnmatched = true;
    addRequired(pp, 'data', @(x) isnumeric(x) && iscolumn(x));
    addRequired(pp, 'startDate', @(x) isscalar(x) && DateWrapper.validateProperDateInput(x));

    % General options
    addParameter(pp, 'Output', "d11", @(x) isstring(x) && ischar(x) && iscellstr(x));
    addParameter(pp, 'ExcludeEmpty', ["automdl"], @isstring);

    % Series specs
    addParameter(pp, 'Series.Precision', 5, @(x) validate.roundScalar(x, 1, 5));
    addParameter(pp, 'Series.Decimals', 5, @(x) validate.roundScalar(x, 1, 5));
    
    % X11 specs
    addParameter(pp, 'X11.Mode', @default, @(x) isequal(x, @default) || validate.anyString(x, 'Add', 'Mult', 'PseudoAdd', 'LogAdd'));
    addParameter(pp, 'X11.Save', string.empty(1, 0), @isstring);
    addParameter(pp, 'X11.SeasonalMA', @default, @(x) isstring(x) || ischar(x));
    addParameter(pp, 'X11.TrendMA', @default, @(x) validate.roundScalar(x, 3, 101) && mod(x, 2)==1);
    addParameter(pp, 'X11.SigmaLim', @default, @(x) isequal(x, @default) || (isnumeric(x) && numel(x)==2 && all(x>0) && x(2)>x(1)));
    addParameter(pp, 'X11.AppendFcst', @default, @(x) isequal(x, @default) || validate.logicalScalar(x));
    addParameter(pp, 'X11.AppendBcst', @default, @(x) isequal(x, @default) || validate.logicalScalar(x));
end

opt = parse(pp, data, startDate, varargin{:});

hereResolveOutputTables( );

code = string.empty(0, 1);
code = [code; series.x13.series(data, startDate, opt)];

listSpecs = ["x11"];
for n = listSpecs
    code = [code; series.x13.compileSpecs(n, opt)];
end

code = join(code, string(newline()));

keyboard

return

    function hereResolveOutputTables( )
        %(
        human = [
            "sf",  "d10"
            "sa",  "d11"
            "tc",  "d12"
            "irr", "d13"
        ];
        mapTables = struct( ...
            "d10", "X11" ...
            , "d11", "X11" ...
            , "d12", "X11" ...
            , "d13", "X11" ...
        );
        outputCodes = string(opt.Output);
        if isscalar(outputCodes)
            outputCodes = regexp(outputCodes, "\w+", "match");
        end
        outputCodes = reshape(lower(outputCodes), 1, [ ]);
        for n = transpose(human)
            inx = outputCodes==n(1);
            outputCodes(inx) = n(2);
        end
        for n = outputCodes
            opt.(mapTables.(n)+"_Save")(end+1) = n;
        end
        %)
    end%
end%




%
% Unit Tests
%
%{
##### SOURCE BEGIN #####
% saveAs=series.x13/seasonUnitTest.m

testCase = matlab.unittest.FunctionTestCase.fromFunction(@(x)x);

%% Test Vanilla

data = randn(40, 1);
data = series.cumsumk(data, 4);

##### SOURCE END #####
%}
