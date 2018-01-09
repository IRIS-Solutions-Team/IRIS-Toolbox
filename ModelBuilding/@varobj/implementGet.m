function [answ, flag] = implementGet(this, query, varargin)
% implementGet  Implement get method for varobj objects
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

answ = [ ];
flag = true;

nAlt = size(this.A, 3);
realSmall = getrealsmall( );

switch query    
    case {'omg', 'omega', 'cove', 'covresiduals'}
        answ = this.Omega;
        
    case {'eig', 'eigval', 'roots'}
        answ = this.EigVal;
        
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
        for ialt = 1 : nAlt
            inx = test(this.EigVal(1, :, ialt));
            answ(1, 1:sum(inx), ialt) = this.EigVal(1, inx, ialt);
        end
        inx = all(isnan(answ), 3);
        answ(:, inx, :) = [ ];
        
    case {'nper', 'nobs'}
        answ = permute(sum(this.IxFitted, 2), [2, 3, 1]);
        
    case {'sample', 'fitted'}
        answ = cell(1, nAlt);
        for ialt = 1 : nAlt
            answ{ialt} = this.Range(this.IxFitted(1, :, ialt));
        end
        
    case {'range'}
        answ = this.Range;
        
    case 'comment'
        % Bkw compatibility only; use comment(this) directly.
        answ = comment(this);
        
    case {'ynames', 'ylist'}
        answ = this.NamesEndogenous;
        
    case {'enames', 'elist'}
        answ = this.NamesErrors;
        
    case {'xnames', 'xlist'}
        answ = this.NamesExogenous;

    case {'inames', 'ilist'}
        answ = this.NamesConditioning;

    case {'ieqtn'}
        answ = this.IEqtn;
        
    case {'zi'}
        % The constant term comes first in Zi, but comes last in user
        % inputs/outputs.
        answ = [this.Zi(:, 2:end), this.Zi(:, 1)];
        
    case {'names', 'list'}
        answ = this.AllNames;
        
    case {'nalt'}
        answ = this.NumVariants;
        
    case {'baseyear'}
        answ = this.BaseYear;
        
    case {'groupnames', 'grouplist'}
        answ = this.GroupNames;
        
    case 'build'
        answ = this.Build;
        
    otherwise
        flag = false;        
end

end
