function This = merge(This,varargin)
% merge  Help provided in +report/merge.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%--------------------------------------------------------------------------

for i = 1 : length(varargin)
    if isa(varargin{i},'report.reportobj')
        n = length(varargin{i}.children);
        for j = 1 : n
            % Add children to `This` report.
            This.children{end+1} = ...
                copy(varargin{i}.children{j});
            % Set the children's parent property to point to
            % `This` report.
            varargin{i}.children{j}.parent = This;
        end
    else
        utils.error('report', ...
            'Can only merge two or more top-level report objects.');
    end
end

end
