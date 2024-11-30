
function [ber]=rayleigh_theory(EbN0dB,M)

N= length(EbN0dB); 
sqM= sqrt(M);
a= 2*(1-power(sqM,-1))/log2(sqM); 
b= 6*log2(sqM)/(M-1);


rn=b*10.^(EbN0dB/10)/2; 
ber = 0.5*a*(1-sqrt(rn./(rn+1))); 

end