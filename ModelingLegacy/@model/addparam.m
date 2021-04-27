function varargout = addparam(varargin)
% addparam  Add model parameters to databank
%
% __Syntax__
%
% Input arguments marked with a `~` sign may be omitted.
%
%     D = addparam(M, ~D)
%
%
% __Input Arguments__
%
% * `M` [ model ] - Model object whose parameters will be added to databank
% `D`.
%
% * `~D` [ struct ] - Databank to which the model parameters will be added;
% if omitted, a new databank will be created.
%
%
% __Output Arguments__
%
% * `D` [ struct ] - Databank with the model parameters added.
%
%
% __Description__
%
% Function `addparam( )` adds all model parameters, including std
% deviations and nonzero cross-correlations, to the databank, `D`, as
% arrays with values for all parameter variants.
%
% Any existing databank entries whose names coincide with the names of
% model parameters will be overwritten.
%
%
% __Example__
%
%     d = struct( );
%     d = addparam(m, d);
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2021 IRIS Solutions Team.

[varargout{1:nargout}] = addToDatabank({'Parameters', 'Std', 'NonzeroCorr'}, varargin{:});

end
