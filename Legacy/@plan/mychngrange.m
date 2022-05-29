function This = mychngrange(This,NewRange)
% mychngrange  [Not a public function] Expand or reduce simulation plan range.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%--------------------------------------------------------------------------

doChkFreq( );
doChngRange( );
This.Start = NewRange(1);
This.End = NewRange(end);


% Nested functions...


%**************************************************************************

    
    function doChkFreq( )
        if ~freqcmp(This.Start,NewRange(1)) ...
                || ~freqcmp(This.End,NewRange(end))
            utils.error('plan', ...
                ['Invalid date frequency of the new range ', ...
                'in subscripted reference to plan object.']);
        end
    end % doChkFreq( )


%**************************************************************************

    
    function doChngRange( )
        nx = size(This.XAnch,1);
        nNReal = size(This.NAnchReal,1);
        nNImag = size(This.NAnchImag,1);
        nc = size(This.CAnch,1);
        
        if ~isinf(NewRange(1))
            if NewRange(1) < This.Start
                nPre = round(This.Start - NewRange(1));
                This.XAnch = [false(nx,nPre),This.XAnch];
                This.NAnchReal = [false(nNReal,nPre),This.NAnchReal];
                This.NAnchImag = [false(nNImag,nPre),This.NAnchImag];
                This.NWghtReal = [zeros(nNReal,nPre),This.NWghtReal];
                This.NWghtImag = [zeros(nNImag,nPre),This.NWghtImag];
                This.CAnch = [false(nc,nPre),This.CAnch];
            elseif NewRange(1) > This.Start
                nPre = round(NewRange(1) - This.Start);
                This.XAnch = This.XAnch(:,nPre+1:end);
                This.NAnchReal = This.NAnchReal(:,nPre+1:end);
                This.NAnchImag = This.NAnchImag(:,nPre+1:end);
                This.NWghtReal = This.NWghtReal(:,nPre+1:end);
                This.NWghtImag = This.NWghtImag(:,nPre+1:end);
                This.CAnch = This.CAnch(:,nPre+1:end);
            end
        end
        
        if ~isinf(NewRange(end))
            if NewRange(end) > This.End
                nPost = round(NewRange(end) - This.End);
                This.XAnch = [This.XAnch,false(nx,nPost)];
                This.NAnchReal = [This.NAnchReal,false(nNReal,nPost)];
                This.NAnchImag = [This.NAnchImag,false(nNImag,nPost)];
                This.NWghtReal = [This.NWghtReal,false(nNReal,nPost)];
                This.NWghtImag = [This.NWghtImag,false(nNImag,nPost)];
                This.CAnch = [This.CAnch,false(nc,nPost)];
            elseif NewRange(end) < This.End
                nPost = round(This.End - NewRange(end));
                This.XAnch = This.XAnch(:,1:end-nPost);
                This.NAnchReal = This.NAnchReal(:,1:end-nPost);
                This.NAnchImag = This.NAnchImag(:,1:end-nPost);
                This.NWghtReal = This.NWghtReal(:,1:end-nPost);
                This.NWghtImag = This.NWghtImag(:,1:end-nPost);
                This.CAnch = This.CAnch(:,1:end-nPost);
            end
        end
    end % doChngRange( )
end % main
