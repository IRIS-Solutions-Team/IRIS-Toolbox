
function [names, tabularObj] = toSheet(inputDb, fileName, varargin)

    tabularObj = Tabular();
    tabularObj.FileName = fileName;
    for i = 1 : 2 : numel(varargin)
        tabularObj.(varargin{i}) = varargin{i+1};
    end
    names = fromDatabank(tabularObj, inputDb);
    save(tabularObj);

end%

