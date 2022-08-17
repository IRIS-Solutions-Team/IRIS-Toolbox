function d = addcorr(this, varargin)

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
