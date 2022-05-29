function warning(id,body,varargin)
% warning  [Not a public function] IRIS warning master file.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%--------------------------------------------------------------------------

try %#ok<TRYNC>
    q = warning('query',['IrisToolbox:',id]);
    if strcmp(q.state, 'off')
        return
    end
end

if ~isempty(body) && body(1)=='#'
    body = utils.hashmessage(body);
end

body = replace(body, "Uncle", "Matlab");
stack = exception.Base.reduceStack(-1);

msg = sprintf('<a href="">IrisToolbox Warning</a> @ %s.',id);
msg = [msg, sprintf(['\n*** ',body],varargin{:})];

% Replace multiple periods with a single period
msg = regexprep(msg,'(?<!\.)\.\.(?!\.)','.'); 

msg = [msg, utils.displaystack(stack)];
state = warning('off', 'backtrace');
warning(['IrisToolbox:',id], '%s', msg);
warning(state);

textual.looseLine( );

end%

