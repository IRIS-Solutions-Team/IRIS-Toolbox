function C = dregexprep(C,Pattern,ReplFunc,InpTokens,varargin)
% dregexprep  [Not a public function] Regexprep with dynamic expressions,
% Matlab-Octave switch.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2020 IRIS Solutions Team.

%--------------------------------------------------------------------------

isChar = ischar(C);
if isChar
    C = {C};
end
inx = strcmpi(varargin,'once');
isOnce = any(inx);
varargin(inx) = [ ];
for i = 1 : length(C)
    from = 1;
    while true
        [start,finish,match,tokens] = ...
            regexp(C{i}(from:end),Pattern, ...
            'once','start','end','match','tokens', ...
            varargin{:});
        if isempty(start)
            break
        end
        args = { };
        if ~isempty(InpTokens)
            args = [{match},tokens];
            args = args(InpTokens+1);
        end
        replString = ReplFunc(args{:});
        start = from + start - 1;
        finish = from + finish - 1;
        C{i} = [C{i}(1:start-1),replString,C{i}(finish+1:end)];
        if isOnce
            break
        end
        from = start + length(replString);
    end
end
if isChar
    C = C{1};
end

end
