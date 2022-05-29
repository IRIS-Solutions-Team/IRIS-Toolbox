function This = assign(This,Opt)
% assign  [Not a public function] Pre-assign attributes.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%--------------------------------------------------------------------------

if ~isempty(Opt)
    This.test = {Opt.test};
    This.format = {Opt.format};
    temp = sprintf('%s,',This.attribute{:});
    temp(end) = '';
    for i = 1 : length(This.test)
        try
            This.test{i} = str2func(['@(',temp,')',This.test{i}]);
        catch %#ok<CTCH>
            This.test{i} = str2func('@(varargin) false');
        end
    end
end

end
