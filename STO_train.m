function [STO_est]= STO_train(yt,LTS_onesym)

nn=1:length(LTS_onesym);

for delay=1:100
    
    corr=abs(yt(delay+nn).*conj(LTS_onesym));
    corr_total(delay)=sum(corr);

end

[max1,index]=max(corr_total);

STO_est=index-32;


end