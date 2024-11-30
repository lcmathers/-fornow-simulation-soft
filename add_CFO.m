%% 加CFO

function y_CFO = add_CFO(y,CFO,Nfft)

% CFO : IFO+FFO

nn=0:length(y)-1;
y_CFO=y.*exp(1j*2*pi*CFO*nn/Nfft);

end