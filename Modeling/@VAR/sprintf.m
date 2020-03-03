function [code, d] = sprintf(this, varargin)
% sprintf  Print VAR model as formatted model code
%
% __Syntax__
%
%     [c, d] = sprintf(v, ...)
%
%
% __Input Arguments__
%
% * `v` [ VAR ] - VAR object that will be printed as a formatted model code.
%
%
% __Output Arguments__
%
% * `c` [ cellstr ] - Text string with the model code for each
% parameterisation.
%
% * `d` [ cell ] - Parameter database for each parameterisation; if
% `'HardParameters='` is true, the databases will be empty.
%
%
% __Options__
%
% * `'Decimal='` [ numeric | *empty* ] - Precision (number of decimals) at
% which the coefficients will be written if `'HardParameters='` is true; if
% empty, the `'Format='` options is used.
%
% * `'Declare='` [ `true` | *`false`* ] - Add declaration blocks and
% keywords for VAR variables, shocks, and equations.
%
% * `'ENames='` [ cellstr | char | *empty* ] - Names that will be given to
% the VAR residuals; if empty, the names from the VAR object will be used.
%
% * `'Format='` [ char | *'%+.16g'* ] - Numeric format for parameter values;
% it will be used only if `'Decimal='` is empty.
%
% * `'HardParameters='` [ *`true`* | `false` ] - Print coefficients as hard
% numbers; otherwise, create parameter names and return a parameter
% database.
%
% * `'YNames='` [ cellstr | char | *empty* ] - Names that will be given to
% the variables; if empty, the names from the VAR object will be used.
%
% * `'Tolerance='` [ numeric | *getrealsmall( )* ] - Treat VAR coefficients
% smaller than `'Tolerance='` in absolute value as zeros; zero coefficients
% will be dropped from the model code.
%
%
% __Description__
%
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 IRIS Solutions Team

persistent parser
if isempty(parser)
    parser = extend.InputParser('VAR.sprintf');
    parser.addRequired(  'VAR', @(x) isa(x, 'VAR'));
    parser.addParameter({'Constant', 'Constants', 'Const'}, true, @validate.logicalScalar);
    parser.addParameter({'Decimal', 'Decimals'}, [ ], @(x) isempty(x) || validate.numericScalar(x));
    parser.addParameter( 'Declare', false, @validate.logicalScalar);
    parser.addParameter({'ENames', 'EName'}, cell.empty(1, 0), @validate.list);
    parser.addParameter( 'Format', '%+.16g', @ischar);
    parser.addParameter({'HardParameters', 'HardParameter'}, true, @validate.logicalScalar);
    parser.addParameter( 'Tolerance', @default, @(x) isa(x, @default) || validate.numericScalar(x));
    parser.addParameter({'YNames', 'YName'}, cell.empty(1, 0), @validate.list);
end
parse(parser, this, varargin{:});
opt = parser.Options;

if isempty(strfind(opt.Format, '%+'))
    utils.error('VAR', ...
        'Format string must contain ''%+'': ''%s''.', opt.Format);
end

if ~isempty(opt.Decimal)
    opt.Format = ['%+.', sprintf('%g', opt.Decimal), 'f'];
end

if isequal(opt.Tolerance, @default)
    opt.Tolerance = this.Tolerance.Solve;
end

%--------------------------------------------------------------------------

ny = size(this.A, 1);
nx = length(this.NamesExogenous);
p = size(this.A, 2) / max(ny, 1);
nv = size(this.A, 3);

if nx>0
    utils.error('VAR:sprintf', ...
        ['VAR objects with exogenous inputs cannot be printed ', ...
        'using sprintf( ) or fprintf( ).']);
end

if ~isempty(opt.YNames)
    this.ynames = opt.YNames;
end
yName = get(this, 'yNames');

if ~isempty(opt.ENames)
    this.enames = opt.ENames;
end
eName = get(this, 'eNames');

% Add time subscripts if missing from the variable names.
for i = 1 : ny
    if isempty(strfind(yName{i}, '{t}'))
        yName{i} = sprintf('%s{t}', yName{i});
    end
end

% Replace time subscripts with hard typed lags.
yName = strrep(yName, '{t}', '{%+g}');
yNameLag = cell(1, ny);
for i = 1 : ny
    yNameLag{i} = cell(1, p+1);
    for j = 0 : p
        yNameLag{i}{1+j} = sprintf(yName{i}, -j);
    end
    yNameLag{i}{1} = strrep(yNameLag{i}{1}, '{-0}', '');
end

% Number of digits for printing parameter indices.
if ~opt.HardParameters
    pDecim = floor(log10(max(ny, p)))+1;
    pDecim = sprintf('%g', pDecim);
    pFormat = ['%', pDecim, 'g'];
end

% Preallocatte output arguments.
code = cell(1, nv);
d = cell(1, nv);

% Cycle over all parameterisations.
for iAlt = 1 : nv
    % Reset the list of parameters for each parameterisation.
    pName = { };
    
    % Retrieve VAR system matrices.
    A = reshape(this.A(:, :, iAlt), [ny, ny, p]);
    K = this.K(:, iAlt);
    if ~opt.Constant
        K(:) = 0;
    end
    B = mybmatrix(this, iAlt);
    c = mycovmatrix(this, iAlt);
	R = covfun.cov2corr(c);
    
    % Print individual equations
    eqn = cell(1, ny);
    d{iAlt} = struct( );
    
    for iEqn = 1 : ny
        % LHS with current-dated endogenous variable
        eqn{iEqn} = [yNameLag{iEqn}{1}, ' ='];
        rhs = false;
        if abs(K(iEqn))>opt.Tolerance || ~opt.HardParameters
            eqn{iEqn} = [ eqn{iEqn}, ' ', ...
                          printParameter('K', {iEqn}, K(iEqn))  ];
            rhs = true;
        end
        
        % Lags of endogenous variables
        for t = 1 : p
            for y = 1 : ny
                if abs(A(iEqn, y, t))>opt.Tolerance || ~opt.HardParameters
                    eqn{iEqn} = [ eqn{iEqn}, ' ', ...
                                  printParameter('A', {iEqn, y, t}, A(iEqn, y, t)), ...
                                  '*',  yNameLag{y}{1+t} ];
                    rhs = true;
                end
            end
        end
        
        % Shocks
        for e = 1 : ny
            value = B(iEqn, e);
            if abs(value)>opt.Tolerance || ~opt.HardParameters
                eqn{iEqn} = [ eqn{iEqn}, ' ', ...
                              printParameter('B', {iEqn, e}, value), ...
                              '*', eName{e} ];
                rhs = true;
            end
        end
        
        if ~rhs
            % If nothing occurs on the RHS, add zero
            eqn{iEqn} = [eqn{iEqn}, ' 0'];
        end
    end
    
    eqn = strrep(eqn, '+1*', '+');

    % Declare variables if requested.
    if opt.Declare
        br = sprintf('\n');
        lead = '    ';
        yName = regexprep(yName, '\{.*\}', '');
        yDecl = textfun.delimlist(yName, 'wrap=', 75, 'lead=', lead);
        eDecl = textfun.delimlist(eName, 'wrap=', 75, 'lead=', lead);
        eqtnDecl = sprintf('\t%s;\n', eqn{:});
        code{iAlt} = [ ...
            '!variables', br, yDecl, br, br, ...
            '!shocks', br, eDecl, br, br, ...
            '!equations', br, eqtnDecl, br, ...
            ];
        if ~opt.HardParameters
            pDecl = textfun.delimlist(pName, 'wrap=', 75, 'lead=', lead);
            code{iAlt} = [code{iAlt}, ...
                '!parameters', br, pDecl, br, ...
                ];
        end
    else
        code{iAlt} = sprintf('%s;\n', eqn{:});
    end
    
    % Add std and corr to the parameter database.
    if ~opt.HardParameters
        for i = 1 : ny
            name = sprintf('std_%s', eName{i});
            d{iAlt}.(name) = sqrt(c(i, i));
            for j = 1 : i-1
                if abs(R(i, j))>opt.Tolerance
                    name = sprintf('corr_%s__%s', eName{i}, eName{j});
                    d{iAlt}.(name) = R(i, j);
                end
            end
        end
    end
end

return




    function x = printParameter(matrix, pos, value)
        if opt.HardParameters
            x = sprintf(opt.Format, value);
        else
            if p<=1 && numel(pos)==3
                pos = pos(1:2);
            end
            x = [matrix, sprintf(pFormat, pos{:})];
            d{iAlt}.(x) = value;
            pName{end+1} = x;
            x = ['+', x];
        end
    end
end
