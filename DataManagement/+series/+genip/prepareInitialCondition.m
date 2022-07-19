function Xi0 = prepareInitialCondition(transition, hard, highRange, inxInit, opt)

    numInit = transition.NumInit;
    if numInit==0
        Xi0 = double.empty(0, 1);
        return
    end

    Xi0 = hard.Level(1:numInit);
    Xi0 = Xi0(end:-1:1);

end%
