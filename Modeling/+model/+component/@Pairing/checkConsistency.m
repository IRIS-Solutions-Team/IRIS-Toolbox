function flag = checkConsistency(pai, qty, eqn)
% checkConsistency  Check internal consistency of object properties
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 IRIS Solutions Team

%--------------------------------------------------------------------------

try
    flag = checkAutoswapSimulate( ) && checkAutoswapSteady( ) ...
           && checkDtrend( ) && checkRevision( );
catch
    flag = false;
end

return

    function flag = checkAutoswapSteady( )
        TYPE = @int8;
        PTR = @int16;
        ix = pai.Autoswap.Steady~=PTR(0);
        flag = all( qty.Type(ix)==TYPE(1) ...
            | qty.Type(ix)==TYPE(2) );
        ptr = abs( pai.Autoswap.Steady(ix) );
        flag = flag && all( qty.Type(ptr)==TYPE(4) );
    end%


    function flag = checkAutoswapSimulate( )
        TYPE = @int8;
        PTR = @int16;
        ixPtr = pai.Autoswap.Dynamic~=PTR(0);
        flag = all( qty.Type(ixPtr)==TYPE(1) ...
            | qty.Type(ixPtr)==TYPE(2) );
        ptr = abs( pai.Autoswap.Dynamic(ixPtr) );
        flag = flag && all( qty.Type(ptr)==TYPE(31) ...
            | qty.Type(ptr)==TYPE(32) );
    end%


    function flag = checkDtrend( )
        TYPE = @int8;
        PTR = @int16;
        ixPtr = pai.Dtrend~=PTR(0);
        ptr = pai.Dtrend(ixPtr);
        flag = all( qty.Type(ptr)==TYPE(1) );
        if ~flag
            return
        end
        
        ixLog = qty.IxLog;
        ixd = eqn.Type==TYPE(3) & ~cellfun(@isempty, eqn.Input);
        lsNameWithLog = qty.Name;
        lsNameWithLog(ixLog) = strcat('log(', lsNameWithLog(ixLog), ')');
        flag = true;
        for i = find(ixd)
            ptr = pai.Dtrend(i);
            lhs = lsNameWithLog{ptr};
            if ~strncmp(eqn.Input{i}, lhs, length(lhs))
                flag = false;
                return
            end
        end
    end%


    function flag = checkRevision( )
        TYPE = @int8;
        ixu = eqn.Type==TYPE(5);
        flag = true;
        for i = find(ixu)
            ptr = pai.Revision(i);
            lhs = [qty.Name{ptr}, '{+1}'];
            if ~strncmp(eqn.Input{i}, lhs, length(lhs))
                flag = false;
                return
            end
        end
    end%
end%

