function [This,UpdateOk] = myupdatemodel(This,X,options)
% myupdatemodel  [Not a public function] Update parameters.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

try
    
    Xcount = 0 ;
    
    if any(strcmpi(options.Select,'activation'))
        This = set(This,'activation',X(Xcount+1:Xcount+This.nActivationParams)) ;
        Xcount = This.nActivationParams ;
    end
    
    if any(strcmpi(options.Select,'hyper'))
        This = set(This,'hyper',X(Xcount+1:Xcount+This.nHyperParams)) ;
        Xcount = Xcount + This.nHyperParams ;
    end
    
    if any(strcmpi(options.Select,'output'))
        This = set(This,'output',X(Xcount+1:Xcount+This.nOutputParams)) ;
    end
    
    UpdateOk = true ;
    
catch
    
    UpdateOk = false ;
    
end

end

