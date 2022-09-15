
function required(minRelease)

    if ischar(minRelease) || isstring(minRelease)
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

