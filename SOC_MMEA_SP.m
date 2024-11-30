function [mu_k,t_domain] = SOC_MMEA_SP(t_initial,F,C,Th,fs,num_ponits,K_Rice,f_los)

Ts=1/fs;

[K,N]=size(F);
mu_k=zeros(K,num_ponits);

for l=0:num_ponits-1
    for k=1:K
        mu_k(k,l+1)=sum(C(k,:).*exp(1j*(2*pi*F(k,:)*(l*Ts+t_initial)+Th(k,:))));
    end
end

for l=0:num_ponits-1
mu_k(1,l+1)=sqrt(1/(K_Rice+1))*mu_k(1,l+1)+sqrt(K_Rice/(K_Rice+1))*exp(1j*(2*pi*f_los*(l*Ts+t_initial)));
end

mu_k([2:K],:)=sqrt(1/(K_Rice+1))*mu_k([2:K],:);

t_domain=[t_initial:Ts:(num_ponits-1)*Ts+t_initial];

end