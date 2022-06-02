
% >=R2019b
%{
function outputDb = control(func, model, inputDb, controlDb, opt)

arguments
    func (1, 2) cell
    model Model
    inputDb {validate.mustBeDatabank}
    controlDb {validate.mustBeDatabank} = struct([])

    opt.Range {validate.mustBeRange} = Inf
    opt.AddToDatabank (1, 1) {local_validateDatabank} = @auto
end
%}
% >=R2019b


% <=R2019a
%(
function outputDb = control(func, model, inputDb, varargin)

persistent ip
if isempty(ip)
    ip = inputParser(); 
    addOptional(ip, "controlDb", struct([]), @validate.mustBeDatabank);
    addParameter(ip, 'Range', Inf);
    addParameter(ip, 'AddToDatabank', @auto);
end
parse(ip, varargin{:});
opt = ip.Results;
controlDb = ip.Results.controlDb;
%)
% <=R2019a


opt.Range = double(opt.Range);

if isempty(controlDb) || isempty(fieldnames(controlDb))
    if any(isinf(opt.Range))
        dbRange = databank.range(inputDb, "sourceNames", string(fieldnames(inputDb)));
        if iscell(dbRange)
            exception.error([
                "Databank:MixedFrequency"
                "Input time series must be all of the same date frequency."
            ]);
        end
    else
        dbRange = opt.Range;
    end
    controlDb = steadydb(model, dbRange);
end

quantity = getp(model, "Quantity");
inx = getIndexByType(quantity, 1, 2, 31, 32);

if isequal(opt.AddToDatabank, @auto)
    outputDb = inputDb;
else
    outputDb = opt.AddToDatabank;
end

needsClip = isinf(opt.Range(1)) && isinf(opt.Range(end));

for pos = reshape(find(inx), 1, [])
    n = quantity.Name{pos};
    if isfield(inputDb, n) && isfield(controlDb, n)
        if quantity.InxLog(pos)
            pos = 2;
        else
            pos = 1;
        end
        %try
            outputSeries = func{pos}(real(inputDb.(n)), real(controlDb.(n)));
            outputSeries = comment(outputSeries, inputDb.(n));
            if needsClip
                outputSeries = clip(outputSeries, opt.Range);
            end
            if isstruct(outputDb)
                outputDb.(n) = outputSeries;
            else
                store(outputDb, n, outputSeries);
            end
        %end
    end
end

end%

%
% Local validators
%

function local_validateDatabank(x)
    %(
    if validate.databank(x) || isequal(x, @auto)
        return
    end
    error("Input value must be a databank (struct or Dictionary) or @auto.");
    %)
end%

