
function [outputDb, tabularObj] = fromSheet(fileName, varargin)

    fileName = reshape(string(fileName), 1, []);
    outputDb = struct();

    tabularObj = Tabular();
    for n = fileName
        tabularObj.FileName = n;
        for i = 1 : 2 : numel(varargin)
            tabularObj.(varargin{i}) = varargin{i+1};
        end
        load(tabularObj);
        outputDb = databank.merge("warning", outputDb, toDatabank(tabularObj));
    end

end%

