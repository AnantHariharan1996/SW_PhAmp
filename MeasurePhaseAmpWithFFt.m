function [ RealAmp,ImagAmp,PhaseOut ] = MeasurePhaseAmpWithFFt( t,vf1,tolerance,period )
% Takes in time series of windowed, filtered, waveform and extracts phase
% and amplitude measurements at a specified period by taking the 
% fft of the waveform.
%
% Oct 2019, Anant Hariharan, anant_hariharan(at)brown.edu
ploton = 0;
N = length(t);
fftout = (1/N)*fftshift(fft(vf1,N));
dt = t(2)-t(1);
df = (1/dt)/N;
sampledx = -N/2:N/2-1;
f = sampledx*df; % create axis of frequencies

fgrab = 1/period;
[meaninglessminval,bestdx] = min(abs(f-fgrab));

% Get phase

fftoutforphase = fftout;
fftoutforphase(abs(fftoutforphase)<tolerance) = 0;
theta = angle(fftoutforphase);
% Make plot for testing
if ploton
subplot(3,1,1)
plot(f,abs(fftout))
xlabel('Frequency (Hz)','interpreter','latex')
ylabel('Absolute Amplitude Spectrum','interpreter','latex')
grid on
grid minor
box on
title(['Real Amp = ' num2str(real(fftout(bestdx))) ', Imaginary 100s Amp = ' num2str(imag(fftout(bestdx)))])
set(gca,'fontsize',14)


subplot(3,1,2)
plot(f,theta)
xlabel('Frequency (Hz)','interpreter','latex')
ylabel('Phase Spectrum','interpreter','latex')
grid on
grid minor
box on
title(['Phase = ' num2str(real(theta(bestdx)))])
set(gca,'fontsize',14)

subplot(3,1,3)

plot(t,vf1)
grid on
box on
grid minor
title('Windowed Filtered Waveform')

end

RealAmp = real(fftout(bestdx));
ImagAmp = imag(fftout(bestdx));
PhaseOut = theta(bestdx);
end

