classdef testFn
    
    properties
        func
        name
        type
        knownMin
        lb = [ ] ;
        ub = [ ] ;
        x0 = [ ] ;
        notes = '' ;
    end
    
    methods
        function This = testFn(func,name,knownMin,varargin)
            options = passvalopt('irisoptim.testfn',varargin{:}) ;
            
            This.x0 = options.x0 ;
            This.lb = options.lb ;
            This.ub = options.ub ;
            This.func = func ;
            This.name = name ;
            This.knownMin = knownMin ;
            This.type = options.type ;
            This.notes = options.notes ;
        end
        
        function [func,x0,knownMin,lb,ub] = setup(This)
            func = This.func ;
            x0 = This.x0 ;
            knownMin = This.knownMin ;
            lb = This.lb ;
            ub = This.ub ;
        end
    end
    
end