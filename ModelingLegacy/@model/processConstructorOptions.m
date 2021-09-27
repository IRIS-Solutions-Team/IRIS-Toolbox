function [this, opt, parserOpt, optimalOpt] = processConstructorOptions(this, varargin)

%( Input parser
persistent pp ppOptimal ppParser
if isempty(pp) || isempty(ppParser) || isempty(ppOptimal)
    pp = extend.InputParser('@Model');
    pp.KeepUnmatched = true;
    pp.PartialMatching = false;
    addParameter(pp, 'AllowExogenous', false, @validate.logicalScalar);
    addParameter(pp, 'Assign', [ ], @(x) isempty(x) || isstruct(x) || validate.nestedOptions(x));
    addParameter(pp, {'baseyear', 'torigin'}, @config, @(x) isequal(x, @config) || isempty(x) || (isnumeric(x) && isscalar(x) && x==round(x)));
    addParameter(pp, {'CheckSyntax', 'ChkSyntax'}, true, @(x) isequal(x, true) || isequal(x, false));
    addParameter(pp, 'Comment', '', @(x) ischar(x) || isstring(x) || iscellstr(x));
    addParameter(pp, {'DefaultStd', 'Std'}, @auto, @(x) isequal(x, @auto) || (isnumeric(x) && isscalar(x) && x>=0));
    addParameter(pp, 'Growth', false, @(x) isequal(x, true) || isequal(x, false));
    addParameter(pp, 'epsilon', [ ], @(x) isempty(x) || (isnumeric(x) && isscalar(x) && x>0 && x<1));
    addParameter(pp, {'removeleads', 'removelead'}, false, @validate.logicalScalar);
    addParameter(pp, 'Linear', false, @(x) isequal(x, true) || isequal(x, false));
    addParameter(pp, 'makebkw', @auto, @(x) isequal(x, @auto) || isequal(x, @all) || iscellstr(x) || ischar(x));
    addParameter(pp, 'Optimal', cell.empty(1, 0), @iscell);
    addParameter(pp, 'OrderLinks', true, @validate.logicalScalar);
    addParameter(pp, {'precision', 'double'}, @(x) ischar(x) && any(strcmp(x, {'double', 'single'})));
    addParameter(pp, 'Preparser', cell.empty(1, 0), @validate.nestedOptions);
    addParameter(pp, 'Refresh', true, @validate.logicalScalar);
    addParameter(pp, {'SavePreparsed', 'SaveAs'}, '', @validate.stringScalar);
    addParameter(pp, {'symbdiff', 'symbolicdiff'}, true, @(x) isequal(x, true) || isequal(x, false) || ( iscell(x) && iscellstr(x(1:2:end)) ));
    addParameter(pp, 'stdlinear', model.DEFAULT_STD_LINEAR, @(x) isnumeric(x) && isscalar(x) && x>=0);
    addParameter(pp, 'stdnonlinear', model.DEFAULT_STD_NONLINEAR, @(x) isnumeric(x) && isscalar(x) && x>=0);


    ppParser = extend.InputParser('@Model');
    ppParser.KeepUnmatched = true;
    ppParser.PartialMatching = false;
    addParameter(ppParser, 'AutodeclareParameters', false, @(x) isequal(x, true) || isequal(x, false));
    addParameter(ppParser, 'EquationSwitch', @auto, @(x) isequal(x, @auto) || validate.anyString(x, 'Dynamic', 'Steady'));
    addParameter(ppParser, {'SteadyOnly', 'SstateOnly'}, @auto, @(x) isequal(x, @auto) || validate.logicalScalar(x));
    addParameter(ppParser, {'AllowMultiple', 'Multiple'}, false, @(x) isequal(x, true) || isequal(x, false));


    ppOptimal = extend.InputParser('@Model');
    ppOptimal.KeepUnmatched = true;
    ppOptimal.PartialMatching = false;
    addParameter(ppOptimal, 'MultiplierPrefix', 'Mu_', @ischar);
    addParameter(ppOptimal, {'Floor', 'NonNegative'}, cell.empty(1, 0), @(x) isempty(x) || (validate.stringScalar(x) && isvarname(x)));
    addParameter(ppOptimal, 'Type', 'Discretion', @(x) ischar(x) && any(strcmpi(x, {'consistent', 'commitment', 'discretion'})));
end
%)

parse(pp, varargin{:});
opt = pp.Options;

% Optimal policy options
optimalOpt = parse(ppOptimal, opt.Optimal{:});

% Parser options
parse(ppParser, pp.UnmatchedInCell{:});
parserOpt = ppParser.Options;
if isequal(parserOpt.EquationSwitch, @auto) && ~isequal(parserOpt.SteadyOnly, @auto)
    % Legacy parser option
    if isequal(parserOpt.SteadyOnly, true)
        parserOpt.EquationSwitch = 'Steady';
    end
end

% Control parameters
unmatched = ppParser.UnmatchedInCell;
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

this.IsLinear = opt.Linear;
this.IsGrowth = opt.Growth;

end%

