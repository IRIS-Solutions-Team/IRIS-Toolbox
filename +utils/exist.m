function Y = exist(X,varargin)

% delete  [Not a public function] Use Java methods to 
% test if a file exists, if possible.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.


if usejava('jvm')
    if nargin>1
        if strncmpi(varargin{1},'dir',3)
            Y = java.io.File(X).isDirectory( ) ;
        elseif strncmpi(varargin{1},'file',4)
            Y = java.io.File(X).isFile( ) ;
        else
            Y = java.io.File(X).exists( ) ;
        end
    else         
        Y = java.io.File(X).exists( ) ;
    end
else
    Y = builtin('exist',X,varargin{:}) ;
    if Y>0
        Y = true ;
    else
        Y = false ;
    end
end

end