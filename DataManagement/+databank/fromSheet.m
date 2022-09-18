
function [outputDb, tabularObj] = fromSheet(fileName, varargin)

    tabularObj = Tabular();
    tabularObj.FileName = fileName;
    for i = 1 : 2 : numel(varargin)
        tabularObj.(varargin{i}) = varargin{i+1};
    end
    load(tabularObj);
    outputDb = toDatabank(tabularObj);

end%
