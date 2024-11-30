function [y_reCFO] = CFO_re(y,CFO_est,Nfft)
%% Compensating the CFO

nn=0:length(y)-1;
y_reCFO=y.*exp(1j*2*pi*(-CFO_est)*nn/Nfft);

end