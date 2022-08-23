function varargout = equationStartsWith(this, varargin)
% equationByLhs  Look up equation by its LHS
%
% Backend IRIS method
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 IRIS Solutions Team

%--------------------------------------------------------------------------

eqtn = reshape(string(this.Input), [ ], 1);
varargout = cellfun(@(x) eqtn(startsWith(eqtn, x)), varargin, 'UniformOutput', false);

end%
