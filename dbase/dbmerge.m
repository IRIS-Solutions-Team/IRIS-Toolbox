function d = dbmerge(varargin)
% dbmerge  Merge two or more databases
%
% __Syntax__
%
%     D = dbmerge(D1, D2, ...)
%
%
% __Input Arguments__
%
% * `D1`, `D2`, ... [ struct ] - Input databases whose entries will be
% combined in the output datase.
%
%
% __Output Arguments__
%
% * `D` [ struct ] - Output database that combines entries from all input
% database; if some entries are found in more than one input databases, the
% last occurence is used.
%
%
% __Description__
%
%
% __Example__
%
%     d1 = struct('a', 1, 'b', 2);
%     d2 = struct('a', 10, 'c', 20);
%     d = dbmerge(d1, d2)
%     d =
%        a: 10
%        b: 2
%        c: 20
%

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 IRIS Solutions Team

%--------------------------------------------------------------------------

if nargin==0
    d = struct( );
    return
end

if nargin==1
    d = varargin{1};
    return
end

names = reshape(fieldnames(varargin{1}), 1, []);
values = reshape(struct2cell(varargin{1}), 1, []);

if nargin==3 && iscellstr(varargin{2})
    % dbmerge(d, names, values)
    names = [names, varargin{2}(:).'];
    values = [values, varargin{3}(:).'];
elseif nargin>2 && iscellstr(varargin(2:2:end-1))
    % dbmerge(d, name, value, name, value, ...)
    names = [names, varargin(2:2:end-1)];
    values = [values, varargin(3:2:end)];
else
    % dbmerge(d1, d2, ...)
    for i = 2 : nargin
        names = [names, fieldnames(varargin{i}).']; %#ok<AGROW>
        values = [values, struct2cell(varargin{i}).']; %#ok<AGROW>
        [namesUnique, posUnique] = unique(names, 'last');
        if length(names)~=length(namesUnique)
            names = namesUnique;
            values = values(posUnique);
        end
    end
end

d = cell2struct(values, cellstr(names), 2);

end%
