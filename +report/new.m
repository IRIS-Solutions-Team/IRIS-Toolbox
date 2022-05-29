function This = new(varargin)
% new  Create new empty report object.
%
% Syntax
% =======
%
%     P = report.new(Cap,...)
%
% Output arguments
% =================
%
% * `P` [ struct ] - Report object with function handles through wich
% the individual report elements can be created.
%
% * `Cap` [ char ] - Report caption; the caption will also be printed on
% the title page of the report if published with the option `'makeTitle='`
% `true`.
%
% Options
% ========
%
% * `'centering='` [ *`true`* | `false` ] - All report elements, except
% [`tex`](report/tex), will be centered on the page.
%
% * `'orientation='` [ *`'landscape'`* | '`portrait`' ] - Paper orientation
% of the published report.
%
% Report options are cascading. You can specify any of an object's options
% in any of his parent (or ascendant) objects.
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%--------------------------------------------------------------------------

This = report.reportobj(varargin{:});
[This,varargin] = specargin(This,varargin{2:end});
This = setoptions(This,struct( ),varargin{:});

end

