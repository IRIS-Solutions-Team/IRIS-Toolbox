function specdisp(this)
% specdisp  Subclass specific disp line.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

% Exogenous inputs.
fprintf('\texogenous: [%g] ', length(this.XNames));
if ~isempty(this.XNames)
    fprintf('%s', textfun.displist(this.XNames));
end
fprintf('\n');

% Conditioning instruments.
fprintf('\tinstruments: [%g] ', length(this.INames));
if ~isempty(this.INames)
    fprintf('%s', textfun.displist(this.INames));
end
fprintf('\n');

end
