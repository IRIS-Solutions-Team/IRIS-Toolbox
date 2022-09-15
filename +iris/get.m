
function varargout = get(varargin)

    irisConfig = iris.Configuration.load();

    if isempty(irisConfig)
        irisConfig = iris.reset("silent", true, "checkId", false, "tex", false);
    end

    if nargin==0
        varargout = { irisConfig };
        return
    end

    varargout = cell(1, nargin);
    for i = 1 : nargin
        ithOptionName = varargin{i};
        varargout{i} = irisConfig.(ithOptionName);
    end

end%

