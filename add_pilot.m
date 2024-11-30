function [X_total] = add_pilot(X,X_pilot,Ndata,Nframe,Nps)

%% Add pilot to a whoel frame symbol

X_total=[];

sym_perframe=Ndata*Nframe;
ip=0;

X_pilot_1=repmat(X_pilot,1,Nframe);


  for nn=1:sym_perframe

      if mod(nn,Nps)==1
          X_total(nn)=X_pilot_1(floor(nn/Nps)+1);
          ip=ip+1;
      else
          X_total(nn)=X(nn-ip);
      end

  end


end