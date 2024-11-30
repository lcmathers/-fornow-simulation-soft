function [x_tr] = frame_generate(X,Nfft,Nsym,Ndata,Nvc,Nframe,X_pilot,Nps)

%% X /modualtion data
%% Nframe /number of frame
%% Train symbol /syn train
%% X_pilot /pilot symbol

Ng=Nsym-Nfft; % CP length

if Nvc==0


kk1=1:Ndata/2;
kk2=Ndata/2+1:Ndata;
kk3=1:Nfft;
kk4=1:Nsym;

x_tr=[];
X_total=[];


X_total=add_pilot(X,X_pilot,Ndata,Nframe,Nps);


for k=1:Nframe

    if Nvc~=0
        X_shift=[0 X_total(kk2) zeros(1,Nvc-1) X_total(kk1)];
    else 
        X_shift=[X_total(kk2) X_total(kk1)];
    end

    x=ifft(X_shift,Nfft)*sqrt(Nfft);
    x_cp=add_CP(x,Nfft,Ng);

    x_tr=[x_tr x_cp];
    
    kk1= kk1+Ndata;
    kk2= kk2+Ndata;
    kk3= kk3+Nfft;
    kk4= kk4+Nsym;

end

else 

        x_tr=[];
        X_total=[];

        for k=1:Nframe

            X_data_current=X((k-1)*Ndata/2+1:k*Ndata/2);

%             X_tx=zeros(1,Nfft);
% 
%             X_tx(pilot_loc_outvc)=[X_pilot(Ndata/4+1:end) X_pilot(1:Ndata/4)];
%             X_tx(loc_Data_outvc)=[X_data_current(Ndata/4+1:end) X_data_current(1:Ndata/4)];

            X_tx=add_pilot_vc(X_data_current,X_pilot,Ndata,Nvc);

            
            x=ifft(X_tx,Nfft)*sqrt(Nfft);

            x_cp=add_CP(x,Nfft,Ng);

            x_tr=[x_tr x_cp];

        end

    
end




% x_tr=[Train_sym x_tr]; % add the STS and LTS

end