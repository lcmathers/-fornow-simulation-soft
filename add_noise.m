function [yt,noise_var] = add_noise(y_channel,SNR_dB,ExtraNoiseSamples,EndNoiseSamples)

%% SNR
%% Extra nosie 前置噪声
%% End noise 尾部噪声

sig_pow = mean(y_channel.*conj(y_channel)); %计算经过衰落信道后的信号能量

noise_var=10.^(-SNR_dB/10)*sig_pow;

y_awgn = y_channel + sqrt(noise_var/2)*(randn(1,length(y_channel))+1j*randn(1,length(y_channel))); % Add noise(AWGN)

extra_noise = sqrt(noise_var/2) * (randn(1,ExtraNoiseSamples) + 1i*randn(1, ExtraNoiseSamples));   % Extranoise

end_noise = sqrt(noise_var/2) * (randn(1,EndNoiseSamples) + 1i*randn(1, EndNoiseSamples)); % Endnoise

yt=[extra_noise y_awgn end_noise];

end