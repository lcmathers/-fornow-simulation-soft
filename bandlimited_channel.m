
function [mu_k_limited,n1]=bandlimited_channel(mu_k,delay_tap)

for n=1:1:201
    for i=1:length(delay_tap)
        n1(n)=n-101;
        band_matrix(n,i)=sinc(delay_tap(i)-n1(n));
    end
end

mu_k_limited=band_matrix*mu_k;

end
