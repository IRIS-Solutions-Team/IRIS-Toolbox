function x = brent(This,a,b,varargin) 
% brent  One dimensional root finding algorithm, reliable as bisection but faster. 
%
%
% Syntax
% =======
%
%     X =  irisoptim.brent(Fun,a,b,...)
%
%
% Input arguments
% ================
%
% * `Fun` [ function_handle ] - Handle to the function to be optimized. 
% 
% * `a` [ numeric ] - Leftr bracket. 
% 
% * `b` [ numeric ] - Right bracket. 
%
%
% Output arguments
% =================
%
% * `X` [ numeric ] - Root. 
%
%
% Options
% ========
%
% * `'tol='` [ numeric | *[1e-4,.9]* ] - Parameters relating
% to backtracking and the Wolfe conditions. 
% 
% * `'maxit='` [ `'off'` | `'final'` | *`'iter'`* ] - Level of display in
% order of increasing verbosity. 
%
% * `'display='` [ numeric | *1* ] - Backpropogation learning rate.
%
%
% Description
% ============
% 
% Finds the root of a univariate function in a compact space using Brent's
% method. Translated from the original C code from the author. 
%
%
% References
% ===========
%
% * Brent, Richard (1973). "Algorithms for minimization without derivatives,"
% Prentice Hall. 

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team and Richard Brent. 

options = passvalopt('irisoptim.brent',varargin{:}) ;

tol = options.tol ;
maxit = options.maxit ;
displayIter = strcmpi(options.display,'iter') ;

Fa = This(a) ;
Fb = This(b) ;
c = a ;
Fc = Fa ;

it = 0 ;
if displayIter
    fprintf(1,'Searching for a root in the interval [%g,%g] using Brent''s method...\n',a,b) ;
end
while it<maxit
    it = it + 1 ;
    
    prevStep = b - a ;
    
    if abs(Fc) < abs(Fb)
        % swap for b to be best approximation
        a = b ;
        b = c ;
        c = a ;
        Fa = Fb ;
        Fb = Fc ;
        Fc = Fa ;
    end
    
    tolAct =  2*eps*abs(b) + tol/2 ;
    
    newStep = (c-b)/2 ;
    
    if abs(newStep) <= tolAct || abs(Fb)<eps
        % acceptable solution found
        x = b ;
        return 
    end
    
    if abs(prevStep) >= tolAct && Fa == Fb
        % previous step was large enough and in the right direction, try
        % interpolation
        cb = c-b ;
        if abs(a-c)<eps
            % if only two distinct points, interpolate linearly
            t1 = Fb/Fa ;
            p = cb*t1 ;
            q = 1 - t1 ;
        else
            % three points, do quadratic inverse  interpolation
            a = Fa/Fc ;
            t1 = Fb/Fc ;
            t2 = Fb/Fa ;
            p = t2*( cb*q*(q-t1) - (b-a)*(t1-1) ) ;
            q = (q-1)*(t1-1)*(t2-1) ;
        end
        if p>0
            q = -q ;
        else
            p = -p ;
        end
        if p < ( 0.75*cb*q-abs(tolAct*q)/2 ) && p < abs(prevStep*q/2)
            newStep = p/q ;
        end
    end
    % step must be at least as large as tolerance
    if abs(newStep)<tolAct
        if newStep>0
            newStep = tolAct ;
        else
            newStep = -tolAct ;
        end
    end
    
    a = b ;
    Fa = Fb ;
    b = b + newStep ;
    Fb = This(b) ;
    if ( Fb > 0 && Fc > 0 ) || ( Fb < 0 && Fc < 0 )
        c = a ;
        Fc = Fa ;
    end
    if displayIter
        fprintf(1,'[%g] Gap = %g, dx = %g\n',it,abs(Fb),newStep) ;
    end
end
if any(strcmpi(options.display,{'iter','final'}))
    fprintf(1,'[%g] Gap = %g, dx = %g\n',it,abs(Fb),newStep) ;
end

end
