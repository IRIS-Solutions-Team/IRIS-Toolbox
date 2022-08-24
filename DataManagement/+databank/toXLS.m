% >=R2019b
%{
function namesSaved = toXLS(inputDb, fileName, opt)

arguments
    inputDb (1, 1) {validate.mustBeDatabank}
    fileName (1, 1) string

    opt.Frequency = @all
    opt.Column (1, 1) double = 1
    opt.Range (1, 1) string = "A1"
end
%}
% >=R2019b


% <=R2019a
%(
function namesSaved = toXLS(inputDb, fileName, varargin)

persistent ip
if isempty(ip)
    ip = inputParser();
    addParameter(ip, "Frequency", @all);
    addParameter(ip, "Column", 1);
    addParameter(ip, "Range", "A1");
end
parse(ip, varargin{:});
opt = ip.Results;
%)
% <=R2019a


[filePath, fileTitle, fileExt] = fileparts(fileName);
fileName = fullfile(string(filePath), string(fileTitle)+".xlsx");

if isequal(opt.Frequency, @all)
    opt.Frequency = [1, 2, 4, 12, 52, 365, 0];
end
opt.Frequency = Frequency(opt.Frequency);

namesSaved = string.empty(1, 0);

for f = reshape(opt.Frequency, 1, [])
    names__ = databank.filterFields(inputDb, "value", @(x) getFrequency(x)==f);
    if isempty(names__)
        continue
    end
    [values__, ~, dates__] = databank.toArray(inputDb, names__, Inf, opt.Column);
    content__ = num2cell(values__);
    dates__ = dater.toDefaultString(reshape(dates__, [], 1));
    content__ = [num2cell(dates__), content__];
    names__ = [{''}, cellstr(reshape(names__, 1, []))];
    content__ = [names__; content__];
    writecell( ...
        content__, fileName ...
        , "writeMode", "overwriteSheet" ...
        , "sheet", string(f) ...
        , "range", opt.Range ...
    );
    namesSaved = [namesSaved, names__];
end

end%

