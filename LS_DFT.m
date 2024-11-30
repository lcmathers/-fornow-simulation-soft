function [H_est_DFT] = LS_DFT(H_est,channel_length)

h_est=ifft(H_est)*sqrt(length(H_est));

h_DFT=[h_est(1:channel_length) zeros(1,length(h_est)-channel_length)];

H_est_DFT=fft(h_DFT)/sqrt(length(H_est));

end