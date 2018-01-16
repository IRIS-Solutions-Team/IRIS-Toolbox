function d = dbmerge(varargin)
% dbmerge  Merge two or more databases.
%
% Syntax
% =======
%
%     D = dbmerge(D1,D2,...)
%
% Input arguments
% ================
%
% * `D1`, `D2`, ... [ struct ] - Input databases whose entries will be
% combined in the output datase.
%
% Output arguments
% =================
%
% * `D` [ struct ] - Output database that combines entries from all input
% database; if some entries are found in more than one input databases, the
% last occurence is used.
%
% Description
% ============
%
% Example
% ========
%
%     d1 = struct('a',1,'b',2);
%     d2 = struct('a',10,'c',20);
%     d = dbmerge(d1,d2)
%     d =
%        a: 10
%        b: 2
%        c: 20
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

%--------------------------------------------------------------------------

if nargin==0
    % No input arguments.
    d = struct( );
    return
end

if nargin==1
    % One input argument.
    d = varargin{1};
    return
end

names = fieldnames(varargin{1}).';
values = struct2cell(varargin{1}).';

if nargin==3 && iscellstr(varargin{2})
    % dbmerge(d,names,values)
    names = [names, varargin{2}(:).'];
    values = [values, varargin{3}(:).'];
elseif nargin>2 && iscellstr(varargin(2:2:end-1))
    % dbmerge(d,name,value,name,value,...)
    names = [names, varargin(2:2:end-1)];
    values = [values, varargin(3:2:end)];
else
    % dbmerge(d1,d2,...)
    for i = 2 : nargin
        names = [names, fieldnames(varargin{i}).']; %#ok<AGROW>
        values = [values, struct2cell(varargin{i}).']; %#ok<AGROW>
    end
end

% Catch indices of last occurences.
[namesUnique, posUnique] = unique(names, 'last');
if length(names)==length(namesUnique)
    d = cell2struct(values, names, 2);
else
    d = cell2struct(values(posUnique), namesUnique, 2);
end

end
