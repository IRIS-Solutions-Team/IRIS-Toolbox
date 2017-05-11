function Y = myeval(This,varargin)
% myeval  [Not a public function] Numerically evaluate sydney.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

if isempty(This.Func)
    if isnumeric(This.args)
        Y = This.args;
        return
    else
        Y = NaN;
    end
else
    args = This.args;
    nArgs = length(args);
    for i = 1 : nArgs
        if isa(args{i},'sydney')
            args{i} = myeval(args{i},varargin{:});
        end
    end
    if strcmp(This.Func,'plus') && nArgs > 2
        % Evaluate plus with more than 2 input arguments.
        Y = feval(This.Func,args{1:2});
        for iArg = 3 : nArgs
            Y = Y + args{iArg};
        end
    else
        Y = feval(This.Func,args{:});
    end
end

end
