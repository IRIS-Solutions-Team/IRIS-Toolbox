function varargout = parse(this, varargin)

iseven = @(x) mod(x, 2)==0;

nInp = length(this.Inp);

state = struct( );
state.Func = this;
state.NUser = length(varargin);
state.IUser = 0;

iUser = 1;

is = false;
try
    is = isequal(this.InpClassName{4}, 'estim');
end
    
for i = 1 : nInp
    state.IUser = iUser; 
    state.NUserLeft = length(varargin);
    
    isValid = false;
    if ~isempty(varargin)
        x = varargin{1};
        state.IsOptAfter = ...
            ~iseven(length(varargin)) && iscellstr(varargin(2:2:end));
        isValid = validate(this.Inp{i}, x, state);
        if isValid
            varargin(1) = [ ];
            iUser = iUser + 1;
        end
    end

    if ~isValid
        x = @invalid;
    end
    
    assign(this.Inp{i}, x);
end

for i = 1 : nInp
    preprocess(this.Inp{i}, this);
end

% Return validated input arguments.
varargout = cell(1, nInp+1);
for i = 1 : nInp
    varargout{i} = this.Inp{i}.Value;
end

% Return remaining options in one cell array.
varargout{end} = varargin;

end
