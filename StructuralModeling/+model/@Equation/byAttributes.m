function list = byAttributes(this, varargin)

inx = byAttributes@model.Insertable(this, varargin{:});
list = string(this.Input(inx));

end%

