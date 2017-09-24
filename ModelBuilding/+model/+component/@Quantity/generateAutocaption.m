function caption = generateAutocaption(this, inp, template, opt)
% generateAutocaption  Create captions for reporting model variables or parameters.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

if isa(inp, 'poster')
    inpList = inp.ParamList;
elseif isstruct(inp)
    inpList = fieldnames(inp);
elseif iscellstr(inp)
    inpList = parser.Helper.parseLabelExprn(inp);
else
    utils.error('model:autocaption', ...
        ['The second input argument must be a poster object, ', ...
        'a struct, or a cellstr.']);
end

% Take the first word, discard all other characters.
inpList = regexp(inpList, '[A-Za-z]\w*', 'match', 'once');

if isempty(template)
    caption = inpList;
    return
end

template = strrep(template, '\\', sprintf('\n'));
opt.std = strrep(opt.std, '\\', sprintf('\n'));
opt.corr = strrep(opt.corr, '\\', sprintf('\n'));

nList = length(inpList);
caption = cell(1,nList);

x = lookup(this, inpList);
for i = 1 : nList
    name = inpList{i};
    if isnan(x.PosName(i)) && isnan(x.PosStdCorr(i))
        caption{i} = inpList{i};
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
    caption{i} = template;
    caption{i} = strrep(caption{i}, '$name$', name);
    caption{i} = strrep(caption{i}, '$label$', label);
    caption{i} = strrep(caption{i}, '$descript$', label); % Bkw compatibility.
    caption{i} = strrep(caption{i}, '$alias$', alias);
end

end
