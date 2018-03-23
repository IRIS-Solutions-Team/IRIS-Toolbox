function [d,c] = clp2dat(varargin)
% clp2dat  Convert text in system clipboard to dates.
%
% Syntax
% =======
%
%     D = clp2dat(...)
%
% Output arguments
% =================
%
% * `D` [ numeric ] - IRIS serial date numbers based on the current content
% of the system clipboard converted by the [`str2dat`](dates/str2dat)
% function.
%
% Options
% ========
%
% See help on [`str2dat`](dates/str2dat) for options available.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.
   
%**************************************************************************

c = clipboard('paste');
c = regexp(c,'(.*?)\n','tokens');
c = [c{:}];
d = str2dat(c,varargin{:});

end
