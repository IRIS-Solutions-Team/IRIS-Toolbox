function this = defineDependent(this, varargin)
% defineDependent  Define dependent term in LinearRegression
%{
%}

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

%--------------------------------------------------------------------------

lhsName = this.LhsName;

if numel(varargin)==1 && validate.string(varargin{1})
    inputString = string(varargin{1});
    if inputString==lhsName
        this.Dependent = regression.Term(this, lhsName);
        return
    end
    transform = regexp(inputString(1), "^(\<[A-Za-z]\w*\>)\(" + lhsName + "\)$", "tokens");
    if ~iscell(transform) || numel(transform)~=1 || numel(transform{1})~=1
        hereThrowInvalidLhs( );
    end
    try
        this.Dependent = regression.Term(this, lhsName, "Transform=", transform{1});
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
        throw(exception.Base(thisError, 'error'), this.LhsNameInDatabank, inputString(1));
    end%
end%

