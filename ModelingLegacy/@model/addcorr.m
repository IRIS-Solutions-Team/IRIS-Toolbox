function d = addcorr(this, varargin)
% addcorr  Add model cross-correlations to databank
%
% __Syntax__
%
% Input arguments marked with a `~` sign may be omitted.
%
%     D = addcorr(M, ~D, ...)
%
%
% __Input Arguments__
%
% * `M` [ model ] - Model object whose model cross-correlations will be added to databank
% `D`.
%
% * `~D` [ struct ] - Databank to which the model cross-correlations  will
% be added; if omitted, a new databank will be created.
%
%
% __Output Arguments__
%
% * `D` [ struct ] - Databank with the model cross-correlations added.
%
%
% __Options__
%
% * `'AddZeroCorr='` [ `true` | *`false`* ] - Add all cross-correlations
% including those set to zero; if `false`, only non-zero cross-correlations
% will be added.
%
%
% __Description__
%
% Any existing databank entries whose names coincide with the names of
% model cross-correlations will be overwritten.
%
%
% __Example__
%
%     d = struct( );
%     d = addcorr(m, d);
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2019 IRIS Solutions Team.

TYPE = @int8;

persistent INPUT_PARSER
if isempty(INPUT_PARSER)
    INPUT_PARSER = extend.InputParser('model/addcorr');
    INPUT_PARSER.addRequired('Model', @(x) isa(x, 'model'));
    INPUT_PARSER.addOptional('Databank', struct( ), @isstruct);
    INPUT_PARSER.addParameter('AddZeroCorr', false, @(x) isequal(x, true) || isequal(x, false));
end
INPUT_PARSER.parse(this, varargin{:});
d = INPUT_PARSER.Results.Databank;

%--------------------------------------------------------------------------

if INPUT_PARSER.Results.AddZeroCorr
    d = addToDatabank('Corr', this, d);
else
    d = addToDatabank('ZeroCorr', this, d);
end

end
