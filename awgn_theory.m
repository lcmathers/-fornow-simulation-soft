
function [ber]=awgn_theory(EbN0dB,M)


N= length(EbN0dB); 
sqM= sqrt(M);
a= 2*(1-power(sqM,-1))/log2(sqM); 
b= 6*log2(sqM)/(M-1);

ber = a*Qfunction(sqrt(b*10.^(EbN0dB/10))); 

% semilogy(EbN0dB,ber);

end

