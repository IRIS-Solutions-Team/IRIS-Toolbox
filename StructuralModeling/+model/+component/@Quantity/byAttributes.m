function list = byAttributes(this, varargin)

inx = byAttributes@model.component.Insertable(this, varargin{:});
list = string(this.Name(inx));

end%

