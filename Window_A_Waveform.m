function [ vf_windowed ] = Window_A_Waveform( t,vf,tukeyon,tukeyratio,centertime,windowlen )
% Implements a time domain window of the waveform around the center
% either boxcar or tukey window...
% tukeytime is time length you want the tukey window to cover...

   lowt = find(t < centertime-windowlen/2);
   hight = find(t > centertime+windowlen/2);
   vf_windowed = vf;
   
   if tukeyon
       %tukey window here 
       
       tukeyidx = find(t > centertime-windowlen/2 & t < centertime+windowlen/2);
       w = tukeywin(length(tukeyidx),tukeyratio);
       vf_windowed(tukeyidx) = vf_windowed(tukeyidx).*w;

   end
       vf_windowed(lowt) = 0;
       vf_windowed(hight) = 0;
   

end

