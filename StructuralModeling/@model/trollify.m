function lsFile = trollify(this, varargin)

ASSIGN_TSERIES_FORMAT = 'DO %s = %.16g + dzero; \n';
ASSIGN_SCALAR_FORMAT = 'DO %s = %.16g; \n';
STEADY_REF_FILENAME = 'SteadyRef.inp';
TIME_STAMP = datestr(now( ));

opt = passvalopt('model.trollify', varargin{:});

switch upper(opt.ParametersAs)
    case 'EXOGENOUS'
        fmt4 = ASSIGN_TSERIES_FORMAT;
        symbolType4 = '';
    case 'PARAMETERS'
        fmt4 = ASSIGN_SCALAR_FORMAT;
        symbolType4 = '''p';
end

TYPE = @int8;
BR = sprintf('\n');
lsFile = cell(1, 0);

nQuan = length(this.Quantity.Name);

validateNames(this.Quantity.Name);

eqtn = [ ...
    this.Equation.Input(this.Equation.Type==TYPE(2)), ...
    this.Equation.Input(this.Equation.Type==TYPE(1)), ...
    ];

label = [ ...
    this.Equation.Label(this.Equation.Type==TYPE(2)), ...
    this.Equation.Label(this.Equation.Type==TYPE(1)), ...
    ];

quan = [ ...
    this.Quantity.Name(this.Quantity.Type==TYPE(2)), ...
    this.Quantity.Name(this.Quantity.Type==TYPE(1)), ...
    ];

[path, modelName, ~] = fileparts(this.FileName);
modelName = strrep(modelName, '_', '');
if ~isequal(opt.ModelName, @auto)
    modelName = opt.ModelName;
end
output = fullfile(path, modelName);

n = numel(eqtn);
ixAssociated = false(1, n);
ixMultiple = false(1, n);
ixMissing = false(1, n);
ixEmpty = false(1, n);
for i = 1 : n
    name = quan{i};
    k = sum(strcmp(label, name));
    if k==0
        ixMissing(i) = true;
    elseif k==1
        ixAssociated(i) = true;
    else
        ixMultiple(i) = true;
    end
    if ~any(strcmp(label{i}, quan))
        ixEmpty(i) = true;
    end
end

isError = false;
if any(~ixAssociated)
    disp('Variables not associated with equations:');
    disp(quan(~ixAssociated));
    isError = true;
end
if any(ixMultiple)
    disp('Multiple occurences:');
    disp(quan(ixMultiple).');
    isError = true;
end
if any(ixMissing)
    disp('Not in any equation:');
    disp(quan(ixMissing).');
    isError = true;
end
if any(ixEmpty)
    disp('Equations not associated with variables:');
    disp(eqtn(ixEmpty).');
    isError = true;
end
if isError
    error('Error trollifying the model object.');
end

okd = true(1, n);
oks = true(1, n);
c = BR;
sref = struct( );
for i = 1 : n
    [d, s, okd(i), oks(i)] = getds(eqtn{i}, label{i});
    d = replaceSteadyRef(d, false);
    s = replaceSteadyRef(s, true);
    c = [c, ...
        sprintf('>> %8s: %s\n', label{i}, d), ...
        sprintf('>> %8s: %s\n', ['SS_', label{i}], s), ...
        BR, ...
        ]; %#ok<AGROW>
end
if ~all(okd)
    disp('Labeled variables not found in their own dynamic equations:');
    disp(label(~okd).');
    isError = true;
end
if ~all(oks)
    disp('Labeled variables not found in their own steady equations:');
    disp(label(~oks).');
    isError = true;
end
if isError
    warning('Error trollifying the model object.');
end

% Declare parameters.
lsp = this.Quantity.Name(this.Quantity.Type==TYPE(4));
for i = 1 : numel(lsp)
    name = lsp{i};
    c = regexprep(c, ['\<', name, '\>'], [name, symbolType4]);
end

src = file2char(opt.SrcTemplate);
src = strrep(src, '$ModelName$', modelName);
src = strrep(src, '$Equations$', c);
src = strrep(src, '$TimeStamp$', TIME_STAMP);

c = cell(1, 40);
for i = 1 : nQuan
    type = this.Quantity.Type(i);
    name = this.Quantity.Name{i};
    value = real( this.Variant.Values(:, i, 1) );
    if type==TYPE(4)
        c{type} = [ c{type}, sprintf(fmt4, name, value) ];
    else
        if isnan(value)
            value = 1;
        end
        c{type} = [ c{type}, sprintf(ASSIGN_TSERIES_FORMAT, name, value) ];
    end
end

ls = fieldnames(sref);
s = '';
if ~isempty(ls)
    %s2d = '';
    for i = 1 : numel(ls)
        name = ls{i};
        namess = [name, opt.SteadyRefSuffix];
        type = 6;
        c{type} = [ c{type}, sprintf('DO %s = %s; \n', namess, name) ];
        s = [s, char(">> SS_" + namess + ": " + namess + char(39) + "n = " + name + ",")];
    end
    %lsFile{end+1} = STEADY_REF_FILENAME;
    %char2file(s2d, STEADY_REF_FILENAME);
end
src = strrep(src, '$SteadyReferences$', s);
char2file(src, [output, '.src']);
lsFile{end+1} = [output, '.src'];

inp = file2char(opt.InpTemplate);
writeInp( );
inp = strrep(inp, '$TimeStamp$', TIME_STAMP);
char2file(inp, opt.InpFileName);
lsFile{end+1} = opt.InpFileName;

return




    function writeInp( )
        rpl = '';
        if ~isempty(c{1})
            rpl = c{1};
        end
        inp = strrep(inp, '$MeasurementVariables$', rpl);
        
        rpl = '';
        if ~isempty(c{2})
            rpl = c{2};
        end
        inp = strrep(inp, '$TransitionVariables$', rpl);
        
        rpl = '';
        if ~isempty(c{31})
            rpl = c{31};
        end
        inp = strrep(inp, '$MeasurementShocks$', rpl);
        
        rpl = '';
        if ~isempty(c{32})
            rpl = c{32};
        end
        inp = strrep(inp, '$TransitionShocks$', rpl);
        
        rpl = '';
        if ~isempty(c{4})
            rpl = c{4};
        end
        inp = strrep(inp, '$Parameters$', rpl);
        
        rpl = '';
        if ~isempty(c{5})
            rpl = c{5};
        end
        inp = strrep(inp, '$ExogenousVariables$', rpl);
        
        rpl = '';
        if ~isempty(c{6})
            rpl = c{6};
        end
        inp = strrep(inp, '$SteadyReferences$', rpl);
        
        inp = regexprep(inp, '\n[ ]*\n[ ]*\n+', '\n\n\n');
    end




    function e = replaceSteadyRef(e, isSteadyEqtn)
        if isSteadyEqtn
            e = regexprep(e, '&(\w+)(''n)?', '$1');
        else
            FN_REPLACE = @replace; %#ok<NASGU>
            e = regexprep(e, '&\w+(''n)?', '${FN_REPLACE($0)}');
        end
        function c = replace(c0)
            c0 = strrep(c0, '&', '');
            c0 = strrep(c0, '''n', '');
            outp = lookup(this.Quantity, c0);
            c = [c0, opt.SteadyRefSuffix, symbolType4];
            sref.(c0) = real( this.Variant.Values(:, outp.IxName, 1) );
        end
    end
end




function [d, s, okd, oks] = getds(eqtn, label)
pos = strfind(eqtn, '!!');
if isempty(pos)
    d = eqtn;
    s = eqtn;
else
    d = [eqtn(1:pos-1), ';'];
    s = eqtn(pos+2:end);
end
% Remove lags and leads from steady equations.
s = regexprep(s, '\{[^\}]+\}', '');
d = rep(d);
s = rep(s);
nd0 = length(d);
ns0 = length(s);
d = regexprep(d, ['\<', label, '\>(?![\(])'], [label, '''n']);
s = regexprep(s, ['\<', label, '\>(?![\(])'], [label, '''n']);
nd = length(d);
ns = length(s);
okd = nd>nd0;
oks = ns>ns0;
    function x = rep(x)
        x = strrep(x, ';', ',');
        x = strrep(x, '^', '**');
        x = strrep(x, '{', '(');
        x = strrep(x, '}', ')');
        x = strrep(x, '[', '(');
        x = strrep(x, ']', ')');
        x = strrep(x, '=#', '=');
    end
end




function validateNames(name)
lsInvalid = {'n', 't'};
lsReport = intersect(lower(name), lower(lsInvalid));
if ~isempty(lsReport)
    throw( exception.Base('Model:TrollifyInvalidName', 'error'), lsReport{:} );
end
end




