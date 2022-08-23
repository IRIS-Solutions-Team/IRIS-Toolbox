% symb2array  Replace symbolic names with references to variable array.
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function eqtn = symb2array(eqtn, type, varargin)

% Replace xN, xNpK, or xNmK back with x(:,N,t+/-K)
% Replace Ln back with L(:,n)

% Make sure we only replace whole words not followed by an opening round
% bracket to avoid conflicts with function names

if nargin>1 && strcmpi(type, 'input')
    name = varargin{1};
    ptn = '([xL])(\d+)(([pm]\d+)?)';
    replaceFunc = @hereReplaceHuman; %#ok<NASGU>
    eqtn = regexprep(eqtn, ptn, '${ replaceFunc($1,$2,$3) }');
else
    eqtn = regexprep(eqtn, ...
        '\<([xL])(\d+)p(\d+)\>(?!\()', '$1($2,t+$3)' );
    eqtn = regexprep(eqtn, ...
        '\<([xL])(\d+)m(\d+)\>(?!\()', '$1($2,t-$3)' );
    eqtn = regexprep(eqtn, ...
        '\<([xL])(\d+)\>(?!\()', '$1($2,t)' );
    % eqtn = regexprep(eqtn, ...
        % '\<g(\d+)\>(?!\()', 'g($1,:)' );
end

return

    function c = hereReplaceHuman(c1, c2, c3)
        pos = sscanf(c2, '%g');
        c = name{pos};
        if strcmp(c1, 'L')
            % c1 is either 'x' or 'L'.
            % 'L' means a sstate reference; add '&' in front of the name.
            c = ['&', c];
        end
        if isempty(c3)
            return
        end
        if c3(1)=='p'
            c = [ c, '{+',c3(2:end), '}' ];
        elseif c3(1)=='m'
            c = [ c, '{-', c3(2:end), '}' ];
        end
    end%
end%

