function s = and(varargin)
% and  Concatenate database entries in 2nd dimension.
%
% Syntax
% =======
%
%     s = s1 & s2
%     s = and(s1, s2, ...)
%
%
% Input arguments
% ================
%
% * `s1`, `s2`, ... [ struct ] - Input databases whose entries will be
% concatenated in 2nd dimension.
%
%
% Output arguments
% =================
%
% * `s` [ struct ] - Output database created by horizontally concatenating
% entries that are present in all `s1`, `s2`, ...
%
%
% Description
% ============
%
% The operator `&` is evaluated by calling the function [`dbfun`](dbfun)
% with concatenation in second dimension. All warnings produced by `dbfun`
% are suppressed in `&`.
%
%
% Example
% ========
%
%     s1 = struct( );
%     s1.a = 1;
%     s1.b = Series(1:10,1);
%     s1.c = 'a';
%     s1.x = 100;
% 
%     s2 = struct( );
%     s2.a = 2;
%     s2.b = Series(5:20,2);
%     s2.c = 'b';
%     s1.y = 200;
% 
%     s = s1 & s2
%     s = 
%         a: [1 2]
%         b: [20x2 tseries]
%         c: 'ab'

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

ixEmpty = cellfun(@isempty, varargin);
if sum(~ixEmpty)==1
    s = varargin{~ixEmpty};
    return
end

%--------------------------------------------------------------------------

q = warning('query');
ide = 'IRIS:Dbase:DbfunReportError';
idw = 'IRIS:Dbase:DbfunReportWarning';
warning('off', ide);
warning('off', idw);

s = dbfun(@horzcat, varargin{:});

warning(q);

end
