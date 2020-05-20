function varargout = season(data, startDate, varargin)

persistent pp
if isempty(pp)
    pp = extend.InputParser('series.x13.series');
    pp.KeepUnmatched = true;
    addRequired(pp, 'data', @(x) isnumeric(x) && iscolumn(x));
    addRequired(pp, 'startDate', @(x) isscalar(x) && DateWrapper.validateProperDateInput(x));

    % General options
    addParameter(pp, 'Output', "x11_d11", @(x) isstring(x) && ischar(x) && iscellstr(x));

    % Series specs
    addParameter(pp, 'Series.ExcludeEmpty', false, @(x) isequal(x, false));
    addParameter(pp, 'Series.Precision', 5, @(x) validate.roundScalar(x, 1, 5));
    addParameter(pp, 'Series.Decimals', 5, @(x) validate.roundScalar(x, 1, 5));
    
    % X11 specs
    addParameter(pp, 'X11.ExcludeEmpty', false, @(x) isequal(x, false));
    addParameter(pp, 'X11.Mode', @default, @(x) isequal(x, @default) || validate.anyString(x, 'Add', 'Mult', 'PseudoAdd', 'LogAdd'));
    addParameter(pp, 'X11.SeasonalMA', @default, @(x) isstring(x) || ischar(x));
    addParameter(pp, 'X11.TrendMA', @default, @(x) validate.roundScalar(x, 3, 101) && mod(x, 2)==1);
    addParameter(pp, 'X11.SigmaLim', @default, @(x) isequal(x, @default) || (isnumeric(x) && numel(x)==2 && all(x>0) && x(2)>x(1)));
    addParameter(pp, 'X11.AppendFcst', @default, @(x) isequal(x, @default) || validate.logicalScalar(x));
    addParameter(pp, 'X11.AppendBcst', @default, @(x) isequal(x, @default) || validate.logicalScalar(x));
end

opt = parse(pp, data, startDate, varargin{:});

outputTables = hereResolveOutputTables( );
specs = struct( );

code = string.empty(0, 1);

code = [code; series.x13.series(data, startDate, opt)];

listSpecs = ["x11"];
for n = listSpecs
    code = [code; series.x13.compileSpecs(n, outputTables, opt)];
end

keyboard

return

    function outputTables = hereResolveOutputTables( )
        
        subs = [
            "sf", "x11_d10"
            "sa", "x11_d11"
            "tc", "x11_d12"
            "irr", "x11_d13"
        ];
        outputCodes = string(opt.Output);
        if isscalar(outputCodes)
            outputCodes = regexp(outputCodes, "\w+", "match");
        end
        outputCodes = replace(reshape(lower(outputCodes), 1, [ ]), ".", "_");
        outputCodes = replace(outputCodes, subs(:, 1), sub(:, 2));
        outputTables = struct( );

        
            
        
    end%
end%
