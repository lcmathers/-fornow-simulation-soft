function [X_pilot,pilot_loc] = generate_pilot(Nfft,Nps,Nvc,Ndata)

%% generate the pilot symbol

Ndata=Nfft-Nvc;

Np=Ndata/Nps; % the number of pilot symbol

pilot_loc=[1:Nps:1+(Np-1)*Nps];

% delete the pilot loc that lies into the VC place

% if Nvc~=0
% 
%     pilot_loc(pilot_loc==1)=0;
% 
%     pilot_loc(pilot_loc>=Ndata/2+2 & pilot_loc<=Ndata/2+Nvc)=0;
% 
%     pilot_loc(pilot_loc==0)=[];
% 
% end


X_pilot=zeros(1,length(pilot_loc));

for k=1:length(pilot_loc)
    X_pilot(k)=exp(1j*pi*(k-1)^2/length(pilot_loc));
end




end