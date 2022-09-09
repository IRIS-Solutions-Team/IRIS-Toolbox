function this = retrieveColumns(this, varargin)

this.Data = this.Data(:, varargin{:});
this.Comment = this.Comment(:, varargin{:});
this = trim(this);

end%
