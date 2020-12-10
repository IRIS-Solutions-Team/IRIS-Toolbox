function ping()

try
    config = iris.Configuration.loadNoReset();
catch
    config = [];
end

if ~isa(config, 'iris.Configuration')
    error(  ...
        "IrisToolbox:ConfigurationDamaged" ...
        , "Configuration data for [IrisToolbox] are not available and need to be reset." ...
    );
end

end%

