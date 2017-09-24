function eqtn = symb2array(eqtn, type, varargin)
% symb2array  Replace symbolic names with references to variable array.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

% Replace xN, xNpK, or xNmK back with x(:,N,t+/-K).
% Replace Ln back with L(:,n).

% Make sure we only replace whole words not followed by an opening round
% bracket to avoid conflicts with function names.

if nargin>1 && strcmpi(type, 'input')
    name = varargin{1};
    ptn = '([xL])(\d+)(([pm]\d+)?)';
    if true % ##### MOSW
        FN_REPLACE = @replaceHuman; %#ok<NASGU>
        eqtn = regexprep(eqtn, ptn, '${ FN_REPLACE($1,$2,$3) }');
    else
        Eqtn = mosw.dregexprep(eqtn, ...
            ptn, @replHuman, [1,2,3]); %#ok<UNRCH>
    end
else
    eqtn = regexprep(eqtn, ...
        '\<([xL])(\d+)p(\d+)\>(?!\()', '$1($2,t+$3)' );
    eqtn = regexprep(eqtn, ...
        '\<([xL])(\d+)m(\d+)\>(?!\()', '$1($2,t-$3)' );
    eqtn = regexprep(eqtn, ...
        '\<([xL])(\d+)\>(?!\()', '$1($2,t)' );
    eqtn = regexprep(eqtn, ...
        '\<g(\d+)\>(?!\()', 'g($1,:)' );
end

return




    function C = replaceHuman(C1, C2, C3)
        pos = sscanf(C2, '%g');
        C = name{pos};
        if strcmp(C1, 'L')
            % C1 is either 'x' or 'L'.
            % 'L' means a sstate reference; add '&' in front of the name.
            C = ['&', C];
        end
        if isempty(C3)
            return
        end
        if C3(1)=='p'
            C = [ C, '{+',C3(2:end), '}' ];
        elseif C3(1)=='m'
            C = [ C, '{-', C3(2:end), '}' ];
        end
    end
end
