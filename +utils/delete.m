function delete(X)
% delete  Use Java delete methods if possible.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.


if usejava('jvm') && isempty(strfind(X, '*')) && isempty(strfind(X, '?'))
    java.io.File(X).delete( ) ;
else
    builtin('delete', X) ;
end

end