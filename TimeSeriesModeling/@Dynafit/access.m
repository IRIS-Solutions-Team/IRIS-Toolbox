function [answ, flag] = access(this, query)

[answ, flag] = access@BaseVAR(this, query);
if flag
    return
end

answ = [ ];
flag = true;

numF = size(this.C, 2);
p = size(this.A, 2)/numF;
nv = countVariants(this);

query = lower(string(query));
query = erase(query, "-");
query = erase(query, ":");
query = char(query);

switch char(query)
    case {'mean', 'std'}
        field = [upper(query(1)), lower(query(2:end))];
        answ = struct();
        names = this.ObservedNames;
        for i = 1 : numel(names)
            try
                answ.(names(i)) = permute(this.(field)(i, :, :), [1, 3, 2]);
            catch
                answ.(names(i)) = nan(1, nv);
            end
        end

    case 'var'
        answ = extractVAR(this);

    case 'sigma'
        answ = this.Sigma;
        
    case 'var'
        answ = VAR(this);
        
    case {'singval', 'sing', 'singvalues', 'singularvalues'}
        answ = this.SingValues;
        
    case {'ny', 'numobserved'}
        answ = size(this.C, 1);
        
    case {'nx', 'nfactor', 'nfactors', 'numfactors'}
        answ = size(this.A, 1);
        
    case 'mean'
        answ = this.Mean;
        
    case 'std'
        answ = this.Std;
        
    otherwise
        flag = false;
end

end
