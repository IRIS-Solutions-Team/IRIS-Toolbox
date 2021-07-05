function list = byAttributes(this, attributes)

inx = byAttributes@model.component.Insertable(this, attributes);
list = string(this.Name(inx));

end%

