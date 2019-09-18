function this = defineDependent(this, varargin)
% defineDependent  Define dependent term in LinearRegression
%{
%}

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

%--------------------------------------------------------------------------

lhsNames = this.LhsNames;

if numel(varargin)==1 && validate.string(varargin{1})
    inputString = string(varargin{1});
    if inputString==lhsNames
        this.Dependent = regression.Term(this, lhsNames);
        return
    end
    transform = regexp(inputString(1), "^(\<[A-Za-z]\w*\>)\(" + lhsNames + "\)$", "tokens");
    if ~iscell(transform) || numel(transform)~=1 || numel(transform{1})~=1
        hereThrowInvalidLhs( );
    end
    try
        this.Dependent = regression.Term(this, lhsNames, "Transform=", transform{1});
    catch
        hereThrowInvalidLhs( );
    end
    return
else
    this.Dependent = regression.Term(this, varargin{:});
    return
end

return


    function hereThrowInvalidLhs( )
        thisError = { 'LinearRegression:InvalidInputString'
                      'Invalid specification of the dependent term in LinearRegression(%1): %s'};
        throw( exception.Base(thisError, 'error'), ...
               join(this.LhsNamesInDatabank, ','), inputString(1) );
    end%
end%

