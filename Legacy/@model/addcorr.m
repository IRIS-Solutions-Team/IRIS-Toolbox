
function d = addcorr(this, varargin)

persistent ip
if isempty(ip)
    ip = inputParser();
    addOptional(ip, 'databank', struct(), @validate.databank);
    addParameter(ip, 'AddZeroCorr', false, @(x) isequal(x, true) || isequal(x, false));
end
parse(ip, varargin{:});
d = ip.Results.databank;


    if ip.Results.AddZeroCorr
        d = addToDatabank('Corr', this, d);
    else
        d = addToDatabank('ZeroCorr', this, d);
    end

end%

