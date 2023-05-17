% retrieveColumns  Create a new time series from columns of an existing
% time series
%
% Backend [IrisToolbox] method
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function this = retrieveColumns(this, varargin)

    if numel(varargin)==1 && isstring(varargin{1})
        varargin{1} = local_getIndexFromComments(this.Headers, varargin{1});
    end

    this.Data = this.Data(:, varargin{:});
    this.Comment = this.Comment(:, varargin{:});
    if ~isempty(this.Headers)
        this.Headers = this.Headers(:, varargin{:});
    end
    this = trim(this);

end%


function index = local_getIndexFromComments(comments, whatToFind)
    %(
    comments = reshape(string(comments), 1, []);
    whatToFind = reshape(string(whatToFind), 1, []);
    index = double.empty(1, 0);
    notFound = string.empty(1, 0);
    for w = whatToFind
        inx = w==comments;
        if ~any(inx)
            notFound(end+1) = w;
            continue
        end
        index(end+1) = find(inx, 1);
    end
    if ~isempty(notFound)
        exception.error([
            "Series"
            "This column does not exist in the time series: %s"
        ], notFound);
    end
    %)
end%

