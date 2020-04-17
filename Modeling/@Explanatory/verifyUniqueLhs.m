function varargout = verifyUniqueLhs(this)

if numel(this)<=1
    flag = true;
    list = string.empty(1, 0);
    return
end

[varargout{1:nargout}] = textual.nonunique([this.LhsName]);
if nargout>=1
    varargout{1} = ~varargout{1};
end

end%

