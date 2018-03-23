function This = parse(Func,varargin)
% parse  Convert Matlab function to sydney object.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

persistent SYDNEY

if ~isa(SYDNEY, 'sydney')
    SYDNEY = sydney( );
end

%--------------------------------------------------------------------------

This = SYDNEY;
This.Func = Func;

if strcmp(Func,'sydney.d')
    This.numd.Func = func2str(varargin{1});
    This.numd.wrt = varargin{2};
    varargin(1:2) = [ ];
end

n = numel(varargin);
This.lookahead = false(1, n);
a = varargin;
for iArg = 1 : n
    if isnumeric(a{iArg})
        % This argument is a plain number.
        x = varargin{iArg};
        a{iArg} = SYDNEY;
        a{iArg}.args = x;
        This.lookahead(iArg) = false;
    else
        This.lookahead(iArg) = any(a{iArg}.lookahead);
    end
end
This.args = a;

end
