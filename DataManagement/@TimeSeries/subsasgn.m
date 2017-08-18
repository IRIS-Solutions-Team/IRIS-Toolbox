function this = subsasgn(this, s, a)

switch s(1).type
case '.'
    this = builtin('subsasgn', this, s, a);
    return
case '{}'
    isRoundScalar = @(x) isnumeric(x) && numel(x)==1 && x==round(x);
    if numel(s)==1 && ~isempty(s(1).subs) && isa(s(1).subs{1}, 'Date')
        this = setData(this, s(1).subs, a);
        this = trim(this);
        return
    end
    assert( ...
        numel(s(1).subs)==1 && isRoundScalar(s(1).subs{1}) ...
        && numel(s)==2 && any(strcmp(s(2).type, {'()', '{}'})) ...
        && ~isempty(s(2).subs) && isa(s(2).subs{1}, 'Date'), ...
        'TimeSeries:subasgn', ...
        'Invalid subscripted assignment to TimeSeries.' ...
    );
    subs = s(2).subs;
    subs{1} = subs{1} + s(1).subs{1};
    this = setData(this, subs, a);
    this = trim(this);
    return
case '()'
    this = setData(this, s(1).subs, a);
    this = trim(this);
    return
otherwise
    error( ...
        'TimeSeries:subsasgn', ...
        'Invalid subscripted assignment to TimeSeries.' ...
    );
end

end
