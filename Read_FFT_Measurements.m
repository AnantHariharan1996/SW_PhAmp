function [ dist,tt,amp,stalon,stalat,evlon,evlat ] = Read_FFT_Measurements( fname,period )
Info = load(fname);

dist = Info(:,1);
stalon = Info(:,6); stalat = Info(:,7);
phase = Info(:,5); amp = Info(:,4); 
evlon = Info(:,8);
evlat = Info(:,9);


% sort by distance prior to unwrapping
distlist = distance(evlat(1),evlon(1),stalat,stalon);
[sortdist,sortdx]= sort(distlist);

dist=dist(sortdx);
stalon=stalon(sortdx);
stalat=stalat(sortdx);
phase=phase(sortdx);
amp = amp(sortdx);
evlon=evlon(sortdx);
evlat=evlat(sortdx);
% QC for bad measurements
idxbad = find(phase == 0);
%
dist(idxbad) = [];
stalon(idxbad) = [];
stalat(idxbad) = [];
phase(idxbad) = [];
amp(idxbad) = [];
evlon(idxbad) = [];
evlat(idxbad) = [];
tt = -1*unwrap(phase)/(2*pi/period);

end

