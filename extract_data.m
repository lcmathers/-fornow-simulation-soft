function [X_data] = extract_data(X_mod,Ndata,Nframe,Nps)

%% get the raw data from the whole frame

sym_perframe=Ndata*Nframe;
ip=0;

for nn=1:sym_perframe
    
    if mod(nn,Nps)==1
        ip=ip+1;
    else 
        X_data(nn-ip)=X_mod(nn);
    end

end

end