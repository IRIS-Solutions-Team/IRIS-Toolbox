function [answ, flag] = access(this, query)

answ = [ ];
flag = true;

numVariants = countVariants(this);
realSmall = getrealsmall( );

switch lower(char(query))
    case {'omg', 'omega', 'cove', 'covresiduals'}
        answ = this.Omega;
        
    case {'eig', 'eigval', 'roots'}
        answ = this.EigVal;

    case 'eigenstability'
        answ = this.EigenStability;
        
    case {'stableroots', 'explosiveroots', 'unstableroots', 'unitroots'}
        switch query
            case 'stableroots'
                test = @(x) abs(x) < (1 - realSmall);
            case {'explosiveroots', 'unstableroots'}
                test = @(x) abs(x) > (1 + realSmall);
            case 'unitroots'
                test = @(x) abs(abs(x) - 1) <= realSmall;
        end
        answ = nan(size(this.EigVal));
        for ialt = 1 : numVariants
            inx = test(this.EigVal(1, :, ialt));
            answ(1, 1:sum(inx), ialt) = this.EigVal(1, inx, ialt);
        end
        inx = all(isnan(answ), 3);
        answ(:, inx, :) = [ ];
        
    case {'nper', 'nobs', 'numperiods'}
        answ = permute(sum(this.IxFitted, 2), [2, 3, 1]);
        
    case {'sample', 'fitted'}
        answ = cell(1, numVariants);
        for ialt = 1 : numVariants
            answ{ialt} = this.Range(this.IxFitted(1, :, ialt));
        end
        
    case {'range'}
        answ = this.Range;
        
    case 'comment'
        % Bkw compatibility only; use comment(this) directly.
        answ = comment(this);

    case 'endogenousnames'
        answ = this.EndogenousNames;
        
    case {'ynames', 'ylist'}
        answ = textual.stringify(this.EndogenousNames);
        
    case 'residualnames'
        answ = this.ResidualNames;

    case {'enames', 'elist'}
        answ = textual.stringify(this.ResidualNames);

    case 'exogenousnames'
        answ = textual.stringify(this.ExogenousNames);
        
    case {'xnames', 'xlist'}
        answ = textual.stringify(this.ExogenousNames);

    case 'conditioningnames'
        answ = textual.stringify(this.ConditioningNames);

    case {'inames', 'ilist'}
        answ = textual.stringify(this.ConditioningNames);

    case {'ieqtn'}
        answ = this.IEqtn;
        
    case {'zi'}
        % The constant term comes first in Zi, but comes last in user
        % inputs/outputs.
        answ = [this.Zi(:, 2:end), this.Zi(:, 1)];
        
    case {'allnames', 'names', 'list'}
        answ = textual.stringify(this.AllNames);
        
    case {'numvariants', 'nalt'}
        answ = countVariants(this);
        
    case {'baseyear'}
        answ = this.BaseYear;
        
    case {'groupnames', 'grouplist'}
        answ = textual.stringify(this.GroupNames);
        
    case 'build'
        answ = this.Build;
        
    otherwise
        flag = false;        
end

end%

