function warning(id,body,varargin)
% warning  [Not a public function] IRIS warning master file.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

try %#ok<TRYNC>
    q = warning('query',['IRIS:',id]);
    if strcmp(q.state, 'off')
        return
    end
end

if ~isempty(body) && body(1)=='#'
    body = utils.hashmessage(body);
end

if true % ##### MOSW
    body = strrep(body,'Uncle','Matlab');
else
    Body = strrep(Body,'Uncle','Octave'); %#ok<UNRCH>
end

stack = exception.Base.reduceStack(-1);

msg = mosw.sprintf('<a href="">IRIS Toolbox Warning</a> @ %s.',id);
msg = [msg,mosw.sprintf(['\n*** ',body],varargin{:})];
% Replace multiple periods with a single period.
msg = regexprep(msg,'(?<!\.)\.\.(?!\.)','.'); 

msg = [msg, utils.displaystack(stack)];
state = warning('off', 'backtrace');
warning(['IRIS:',id], '%s', msg);
warning(state);

textfun.loosespace( );

end
