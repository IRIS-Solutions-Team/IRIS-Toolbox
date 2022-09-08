
function set(varargin)

if nargin==0
    return
end

if nargin==1
    if ~isa(varargin{1}, 'iris.Configuration')
        error( 'IRIS:Configuration:NotAConfigurationObject', ...
               'If iris.set(~) is called with a single input argument, it must be an iris.Configuration object' );
    end
    irisConfig = varargin{1};
    save(irisConfig);
    return
end

irisConfig = iris.Configuration.load();

for i = 1 : 2 : numel(varargin)
    ithOptionName = varargin{i};
    ithOptionName = strrep(ithOptionName, '=', '');
    ithNewValue = varargin{i+1};
    irisConfig.(ithOptionName) = ithNewValue;
end

save(irisConfig);

end%

