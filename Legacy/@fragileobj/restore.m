function C = restore(C,This,varargin)
% restore  [Not a public function] Replace protected charcodes with
% original strings.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

islogicalscalar = @(x) islogical(x) && isscalar(x);

%(
defaults = { ...
    'delimiter,delimiters',true,islogicalscalar, ...
};
%)

opt = passvalopt(defaults, varargin{:});

%--------------------------------------------------------------------------

% Return immediately.
if isempty(C) || isempty(This)
    return
end

ptn = regexppattern(This);
rplFunc = @doReplace; %#ok<NASGU>
C = regexprep(C,ptn,'${rplFunc($0)}');


    function C = doReplace(C0)
        K = char2dec(This,C0) - This.Offset;
        C = This.Store{K};
        if opt.delimiter
            C = [This.Open{K},C,This.Close{K}];
        end
    end % doReplace( )


end
