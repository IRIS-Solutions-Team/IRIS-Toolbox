function This = autodata(This)
% autodata  [Not a public function] Create additional rows of autodata in a table series.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%--------------------------------------------------------------------------

nauto = numel(This.options.autodata);
for j = 1 : length(This.data)
    newData = cell(1,nauto);
    for i = 1 : nauto
        newData{i} = This.options.autodata{i}(This.data{j});
    end
    This.data{j} = [This.data{j},newData{:}];
end

end

