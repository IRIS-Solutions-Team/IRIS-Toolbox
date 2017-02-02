function [Code,D] = sprintf(This,varargin)
% sprintf  Print VAR model as formatted model code.
%
% Syntax
% =======
%
%     [C,D] = sprintf(V,...)
%
% Input arguments
% ================
%
% * `V` [ VAR ] - VAR object that will be printed as a formatted model code.
%
% - Output arguments
%
% * `C` [ cellstr ] - Text string with the model code for each
% parameterisation.
%
% * `D` [ cell ] - Parameter database for each parameterisation; if
% `'hardParameters='` is true, the databases will be empty.
%
% Options
% ========
%
% * `'decimal='` [ numeric | *empty* ] - Precision (number of decimals) at
% which the coefficients will be written if `'hardParameters='` is true; if
% empty, the `'format='` options is used.
%
% * `'declare='` [ `true` | *`false`* ] - Add declaration blocks and
% keywords for VAR variables, shocks, and equations.
%
% * `'eNames='` [ cellstr | char | *empty* ] - Names that will be given to
% the VAR residuals; if empty, the names from the VAR object will be used.
%
% * `'format='` [ char | *'%+.16g'* ] - Numeric format for parameter values;
% it will be used only if `'decimal='` is empty.
%
% * `'hardParameters='` [ *`true`* | `false` ] - Print coefficients as hard
% numbers; otherwise, create parameter names and return a parameter
% database.
%
% * `'yNames='` [ cellstr | char | *empty* ] - Names that will be given to
% the variables; if empty, the names from the VAR object will be used.
%
% * `'tolerance='` [ numeric | *getrealsmall( )* ] - Treat VAR coefficients
% smaller than `'tolerance='` in absolute value as zeros; zero coefficients
% will be dropped from the model code.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

% Parse options.
opt = passvalopt('VAR.sprintf',varargin{:});

if isempty(strfind(opt.format,'%+'))
    utils.error('VAR', ...
        'Format string must contain ''%+'': ''%s''.',opt.format);
end

if ~isempty(opt.decimal)
    opt.format = ['%+.',sprintf('%g',opt.decimal),'e'];
end

%--------------------------------------------------------------------------

ny = size(This.A,1);
nx = length(This.XNames);
p = size(This.A,2) / max(ny,1);
nAlt = size(This.A,3);

if nx > 0
    utils.error('VAR:sprintf', ...
        ['VAR objects with exogenous inputs cannot be printed ', ...
        'using sprintf( ) or fprintf( ).']);
end

if ~isempty(opt.ynames)
    This.ynames = opt.ynames;
end
yName = get(This,'yNames');

if ~isempty(opt.enames)
    This.enames = opt.enames;
end
eName = get(This,'eNames');

% Add time subscripts if missing from the variable names.
for i = 1 : ny
    if isempty(strfind(yName{i},'{t}'))
        yName{i} = sprintf('%s{t}',yName{i});
    end
end

% Replace time subscripts with hard typed lags.
yName = strrep(yName,'{t}','{%+g}');
yNameLag = cell(1,ny);
for i = 1 : ny
    yNameLag{i} = cell(1,p+1);
    for j = 0 : p
        yNameLag{i}{1+j} = sprintf(yName{i},-j);
    end
    yNameLag{i}{1} = strrep(yNameLag{i}{1},'{-0}','');
end

% Number of digits for printing parameter indices.
if ~opt.hardparameters
    pDecim = floor(log10(max(ny,p)))+1;
    pDecim = sprintf('%g',pDecim);
    pFormat = ['%',pDecim,'g'];
end

% Preallocatte output arguments.
Code = cell(1,nAlt);
D = cell(1,nAlt);

% Cycle over all parameterisations.
for iAlt = 1 : nAlt
    
    % Reset the list of parameters for each parameterisation.
    pName = { };
    
    % Retrieve VAR system matrices.
    A = -reshape(This.A(:,:,iAlt),[ny,ny,p]);
    K = This.K(:,iAlt);
    if ~opt.constant
        K(:) = 0;
    end
    B = mybmatrix(This, iAlt);
    C = mycovmatrix(This, iAlt);
	R = covfun.cov2corr(C);
    
    % Print individual equations.
    eqtn = cell(1,ny);
    D{iAlt} = struct( );
    
    for eq = 1 : ny
        
        % LHS with current-dated endogenous variable.
        eqtn{eq} = [yNameLag{eq}{1},' ='];
        rhs = false;
        if abs(K(eq)) > opt.tolerance || ~opt.hardparameters
            eqtn{eq} = [eqtn{eq},' ', ...
                doPrintParameter('K',{eq},K(eq))];
            rhs = true;
        end
        
        % Lags of endogenous variables.
        for t = 1 : p
            for y = 1 : ny
                if abs(A(eq,y,t)) > opt.tolerance || ~opt.hardparameters
                    eqtn{eq} = [eqtn{eq},' ', ...
                        doPrintParameter('A',{eq,y,t},A(eq,y,t)),'*', ...
                        yNameLag{y}{1+t}];
                    rhs = true;
                end
            end
        end
        
        % Shocks.
        for e = 1 : ny
            if abs(B(eq,e)) > opt.tolerance || ~opt.hardparameters
                eqtn{eq} = [eqtn{eq},' ', ...
                    doPrintParameter('B',{eq,e},B(eq,e)),'*',eName{e}];
                rhs = true;
            end
        end
        
        if ~rhs
            % If nothing occurs on the RHS, add zero.
            eqtn{eq} = [eqtn{eq},' 0'];
        end
    end
    
    % Declare variables if requested.
    if opt.declare
        br = sprintf('\n');
        lead = '    ';
        yName = regexprep(yName,'\{.*\}','');
        yDecl = textfun.delimlist(yName, 'wrap=', 75, 'lead=', lead);
        eDecl = textfun.delimlist(eName, 'wrap=', 75, 'lead=', lead);
        eqtnDecl = sprintf('\t%s;\n',eqtn{:});
        Code{iAlt} = [ ...
            '!variables',br,yDecl,br,br, ...
            '!shocks',br,eDecl,br,br, ...
            '!equations',br,eqtnDecl,br, ...
            ];
        if ~opt.hardparameters
            pDecl = textfun.delimlist(pName, 'wrap=', 75, 'lead=', lead);
            Code{iAlt} = [Code{iAlt}, ...
                '!parameters',br,pDecl,br, ...
                ];
        end
    else
        Code{iAlt} = sprintf('%s;\n',eqtn{:});
    end
    
    % Add std and corr to the parameter database.
    if ~opt.hardparameters
        for i = 1 : ny
            name = sprintf('std_%s',eName{i});
            D{iAlt}.(name) = sqrt(C(i,i));
            for j = 1 : i-1
                if abs(R(i,j)) > opt.tolerance
                    name = sprintf('corr_%s__%s',eName{i},eName{j});
                    D{iAlt}.(name) = R(i,j);
                end
            end
        end
    end
    
end


% Nested functions...


%**************************************************************************
    function X = doPrintParameter(Matrix,Pos,Value)
        if opt.hardparameters
            X = sprintf(opt.format,Value);
        else
            if p <= 1 && numel(Pos) == 3
                Pos = Pos(1:2);
            end
            X = [Matrix,sprintf(pFormat,Pos{:})];
            D{iAlt}.(X) = Value;
            pName{end+1} = X;
            X = ['+',X];
        end
    end % doPrintParameter( )


end
