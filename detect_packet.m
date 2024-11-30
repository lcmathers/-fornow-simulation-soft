function [final_result] = detect_packet(rx_signal,STS,SNR_dB,Nfft)

%% Xp_st /short train symbol

delay_max=1000;

result=zeros(1,delay_max);

l=length(STS)/10;
nn=1:1:l;

Y=rx_signal*sqrt(Nfft);

for delay=1:delay_max

    corr=0;
    sig_power=0;

    corr=abs(sum(Y(nn+delay).*conj(Y(nn+delay+l)))); % auto_correlation
    sig_power=sum(abs(Y(nn+delay+l))); % signal_power

    result(delay)=(corr/sig_power)^2;


end

SNR=10.^(SNR_dB/10);
th=0.75*(SNR/(1+SNR)).^2;


max_result=0;
index1=0;
iter=0;
% th=0.5*max(result);

for i=1:length(result)

    if (result(i)>=th)
        iter=iter+1;
    end

    if iter>=1.5*l
        index1=i-1.5*l+1;
        break;
    end

end

final_result=index1;

end