function I = myfourierdata(DATA,OPT)
% MYFOURIERDATA  [Not a public function] Convert time-domain data to freq-domain data for likelihood.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2019 IRIS Solutions Team.

%**************************************************************************

DATA = DATA(~OPT.exclude,:,:);
[ny,nper,ndata] = size(DATA);
N = 1 + floor(nper/2);

I = nan(ny,ny*nper,ndata);

for idata = 1 : ndata
    fdata = fft(DATA(:,:,idata).');
    
    % Sample SGF.
    Ii = [ ];
    for j = 1 : N
        Ii = [Ii,fdata(j,:)'*fdata(j,:)]; %#ok<AGROW>
    end
    I(:,1:ny*N,idata) = Ii;
    
end

% Do not divide by 2*pi because we skip mutliplying by 2*pi in L1 in
% `myfdlik`.
I = I/nper;

end