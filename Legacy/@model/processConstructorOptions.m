function [opt, parserOpt, optimalOpt] = processConstructorOptions(this, varargin)

%( Input parser
persistent ip ipOptimal ipParser
if isempty(ip) || isempty(ipParser) || isempty(ipOptimal)
    ip = extend.InputParser();
    ip.KeepUnmatched = true;
    ip.PartialMatching = false;
    addParameter(ip, 'AllowExogenous', false, @validate.logicalScalar);
    addParameter(ip, 'Assign', [ ], @(x) isempty(x) || isstruct(x) || validate.nestedOptions(x));
    addParameter(ip, {'baseyear', 'torigin'}, @config, @(x) isequal(x, @config) || isempty(x) || (isnumeric(x) && isscalar(x) && x==round(x)));
    addParameter(ip, {'CheckSyntax', 'ChkSyntax'}, true, @(x) isequal(x, true) || isequal(x, false));
    addParameter(ip, "ThrowErrorAs", "error", @(x) ismember(lower(x), ["error", "warning"]));
    addParameter(ip, 'Comment', '', @(x) ischar(x) || isstring(x) || iscellstr(x));
    addParameter(ip, {'DefaultStd', 'Std'}, @auto, @(x) isequal(x, @auto) || (isnumeric(x) && isscalar(x) && x>=0));
    addParameter(ip, 'Growth', false, @(x) isequal(x, true) || isequal(x, false));
    addParameter(ip, 'epsilon', [ ], @(x) isempty(x) || (isnumeric(x) && isscalar(x) && x>0 && x<1));
    addParameter(ip, {'removeleads', 'removelead'}, false, @validate.logicalScalar);
    addParameter(ip, 'Linear', false, @(x) isequal(x, true) || isequal(x, false));
    addParameter(ip, 'makebkw', @auto, @(x) isequal(x, @auto) || isequal(x, @all) || iscellstr(x) || ischar(x));
    addParameter(ip, 'Optimal', cell.empty(1, 0), @iscell);
    addParameter(ip, 'OrderLinks', true, @validate.logicalScalar);
    addParameter(ip, {'precision', 'double'}, @(x) ischar(x) && any(strcmp(x, {'double', 'single'})));
    addParameter(ip, 'Preparser', cell.empty(1, 0), @validate.nestedOptions);
    addParameter(ip, 'Refresh', true, @validate.logicalScalar);
    addParameter(ip, {'SavePreparsed', 'SaveAs'}, '', @validate.stringScalar);
    addParameter(ip, {'symbdiff', 'symbolicdiff'}, true, @(x) isequal(x, true) || isequal(x, false) || ( iscell(x) && iscellstr(x(1:2:end)) ));
    addParameter(ip, 'stdlinear', model.DEFAULT_STD_LINEAR, @(x) isnumeric(x) && isscalar(x) && x>=0);
    addParameter(ip, 'stdnonlinear', model.DEFAULT_STD_NONLINEAR, @(x) isnumeric(x) && isscalar(x) && x>=0);


    ipParser = extend.InputParser();
    ipParser.KeepUnmatched = true;
    ipParser.PartialMatching = false;
    addParameter(ipParser, 'AutodeclareParameters', false, @(x) isequal(x, true) || isequal(x, false));
    addParameter(ipParser, 'EquationSwitch', @auto, @(x) isequal(x, @auto) || validate.anyString(x, 'Dynamic', 'Steady'));
    addParameter(ipParser, 'SteadyOnly', @auto, @(x) isequal(x, @auto) || validate.logicalScalar(x));
    addParameter(ipParser, 'AllowMultiple', false, @(x) isequal(x, true) || isequal(x, false));


    ipOptimal = extend.InputParser();
    ipOptimal.KeepUnmatched = true;
    ipOptimal.PartialMatching = false;
    addParameter(ipOptimal, 'MultiplierPrefix', 'Mu_', @ischar);
    % addParameter(ipOptimal, 'NonNegative', cell.empty(1, 0), @(x) isempty(x) || (validate.stringScalar(x) && isvarname(x)));
    addParameter(ipOptimal, 'Type', 'Discretion', @(x) ischar(x) && any(strcmpi(x, {'consistent', 'commitment', 'discretion'})));
end
%)

opt = parse(ip, varargin{:});

% Optimal policy options
optimalOpt = parse(ipOptimal, opt.Optimal{:});

% Parser options
parserOpt = parse(ipParser, ip.UnmatchedInCell{:});
if isequal(parserOpt.EquationSwitch, @auto) && ~isequal(parserOpt.SteadyOnly, @auto)
    % Legacy parser option
    if isequal(parserOpt.SteadyOnly, true)
        parserOpt.EquationSwitch = 'Steady';
    end
end

% Control parameters
unmatched = ipParser.UnmatchedInCell;
if ~isstruct(opt.Assign)
    if iscell(opt.Assign)
        newAssign = struct( );
        for i = 1 : 2 : numel(opt.Assign)
            name = strip(erase(string(opt.Assign{i}), "="));
            value = opt.Assign{i+1};
            newAssign.(name) = value;
        end
        opt.Assign = newAssign;
    else
        opt.Assign = struct( );
    end
end

% Legacy options
for i = 1 : 2 : numel(unmatched)
    opt.Assign.(unmatched{i}) = unmatched{i+1};
end

end%

