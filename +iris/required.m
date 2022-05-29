function required(minRelease)
% iris.required  Throw error if the [IrisToolbox] Release currently running fails to comply with the required minimum
%{
% ## Syntax ##
%
%     iris.required(V)
%
%
% ## Input Arguments ##
%
% __`V`__ [ char ] -
% Text string describing the oldest acceptable distribution of
% [IrisToolbox].
%
%
% ## Description ##
%
% If the [IrisToolbox] release present on the computer does not comply with
% the minimum requirement `V`, an error is thrown.
%
%
% ## Example ##
%
% These two calls to `iris.required` are equivalent:
%
%     iris.required(20111222)
%     iris.required('20111222')
%}

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 IRIS Solutions Team

%--------------------------------------------------------------------------

if ischar(minRelease)
    minRelease = sscanf(minRelease, '%g', 1);
end
if ~isnumeric(minRelease) || ~isscalar(minRelease) || ~isfinite(minRelease)
    error( 'IrisToolbox:Config:ReleaseRequired', ...
           'Invalid input argument to iris.required' );
end

[vChar, vNum] = iris.release( );

if vNum<minRelease
    thisError = { 'IrisToolbox:Config:ReleaseRequired'
                  '[IrisToolbox] Release %d or later is required; '
                  'you are currently running Release %s' };
    error(thisError{1}, [thisError{2:end}], minRelease, vChar);
end

end%

