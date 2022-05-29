% checkConsistency  Check internal consistency of object properties
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function flag = checkConsistency(pai, qty, eqn)

try
    flag = hereCheckAutoswapsSimulate() ...
        && hereCheckAutoswapsSteady() ...
        && hereCheckDtrends();
catch
    flag = false;
end

return

    function flag = hereCheckAutoswapsSteady()
        PTR = @int16;
        inx = pai.Autoswaps.Steady~=PTR(0);
        flag = all(qty.Type(inx)==1 | qty.Type(inx)==2);
        ptr = abs( pai.Autoswaps.Steady(inx) );
        flag = flag && all(qty.Type(ptr)==4);
    end%


    function flag = hereCheckAutoswapsSimulate()
        PTR = @int16;
        inxPtr = pai.Autoswaps.Dynamic~=PTR(0);
        flag = all( qty.Type(inxPtr)==1 ...
            | qty.Type(inxPtr)==2 );
        ptr = abs(pai.Autoswaps.Dynamic(inxPtr));
        flag = flag && all(qty.Type(ptr)==31 | qty.Type(ptr)==32);
    end%


    function flag = hereCheckDtrends()
        PTR = @int16;
        inxPtr = pai.Dtrends~=PTR(0);
        ptr = pai.Dtrends(inxPtr);
        flag = all( qty.Type(ptr)==1 );
        if ~flag
            return
        end

        inxLog = qty.IxLog;
        inxd = eqn.Type==3 & ~cellfun(@isempty, eqn.Input);
        listNameWithLog = qty.Name;
        listNameWithLog(inxLog) = strcat('log(', listNameWithLog(inxLog), ')');
        flag = true;
        for i = find(inxd)
            ptr = pai.Dtrends(i);
            lhs = listNameWithLog{ptr};
            if ~strncmp(eqn.Input{i}, lhs, numel(lhs))
                flag = false;
                return
            end
        end
    end%
end%

