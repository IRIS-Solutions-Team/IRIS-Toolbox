% generateAutocaption  Create captions for reporting model variables or parameters
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function captions = generateAutocaption(this, inp, template, opt)

if isa(inp, 'poster')
    inputList = cellstr(inp.ParameterNames);
elseif isstruct(inp)
    inputList = fieldnames(inp);
elseif iscellstr(inp) || isstring(inp)
    inp = cellstr(inp);
    inputList = parser.Helper.parseLabelExprn(inp);
else
    utils.error('model:autocaption', ...
        ['The second input argument must be a poster object, ', ...
        'a struct, or a cellstr.']);
end

% Take the first word, discard all other characters.
inputList = regexp(inputList, '[A-Za-z]\w*', 'match', 'once');

if isempty(template)
    captions = inputList;
    return
end

template = strrep(template, '\\', sprintf('\n'));
opt.std = strrep(opt.std, '\\', sprintf('\n'));
opt.corr = strrep(opt.corr, '\\', sprintf('\n'));

nList = length(inputList);
captions = cell(1,nList);

x = lookup(this, inputList);
for i = 1 : nList
    name = inputList{i};
    if isnan(x.PosName(i)) && isnan(x.PosStdCorr(i))
        captions{i} = inputList{i};
        continue
    end
    if ~isnan(x.PosName(i))
        % This is a plain name.
        label = this.Label{x.PosName(i)};
        alias = this.Alias{x.PosName(i)};
    elseif ~isnan(x.PosStdCorr(i)) && ~isnan(x.PosShk1(i)) && isnan(x.PosShk2(i))
        % This is a std name, x.PosStdCorr(i) is between 1 and ne.
        label = opt.std;
        alias = opt.std;
        label = strrep(label, '$shock$', this.Label{x.PosShk1(i)});
        alias = strrep(alias, '$shock$', this.Alias{x.PosShk1(i)});
    else
        % This is a corr name.
        label = opt.corr;
        alias = opt.corr;
        label = strrep(label, '$shock1$', this.Label{x.PosShk1(i)});
        label = strrep(label, '$shock2$', this.Label{x.PosShk2(i)});
        alias = strrep(alias, '$shock1$', this.Alias{x.PosShk1(i)});
        alias = strrep(alias, '$shock2$', this.Alias{x.PosShk2(i)});
    end
    captions{i} = template;
    captions{i} = strrep(captions{i}, '$name$', name);
    captions{i} = strrep(captions{i}, '$label$', label);
    captions{i} = strrep(captions{i}, '$descript$', label); % Bkw compatibility.
    captions{i} = strrep(captions{i}, '$alias$', alias);
end

end
