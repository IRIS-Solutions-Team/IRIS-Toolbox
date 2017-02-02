function s = and(s1, s2)
% and  Concatenate database entries in 2nd dimension.
%
% Syntax
% =======
%
%     S = S1 & S2
%
%
% Input arguments
% ================
%
% * `S1`, `S2` [ struct ] - Input databases whose entries will be
% concatenated in 2nd dimension.
%
%
% Output arguments
% =================
%
% * `S` [ struct ] - Output database created by horizontally concatenating
% entries that are present in both `S1` and `S2`.
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
% -Copyright (c) 2007-2017 IRIS Solutions Team.

if isempty(s1)
    s = s2;
    return
elseif isempty(s2)
    s = s1;
    return
end

%--------------------------------------------------------------------------

q = warning('query');
ide = 'IRIS:Dbase:DbfunReportError';
idw = 'IRIS:Dbase:DbfunReportWarning';
warning('off', ide);
warning('off', idw);

s = dbfun(@horzcat, s1, s2);

warning(q);

end
