function [X_tx] = add_pilot_vc(X_data_current,X_pilot,Ndata,Nvc)

Nfft=Ndata+Nvc;

pilot_loc=[1:2:2047];
        
pilot_loc_outvc=pilot_loc;
pilot_loc_outvc(pilot_loc_outvc==1)=[];
pilot_loc_outvc((pilot_loc_outvc>=(Ndata/2+2)) & (pilot_loc_outvc<=(Ndata/2+Nvc)))=[];
pilot_loc_vc=[1 pilot_loc(find(pilot_loc>=(Ndata/2+2) & (pilot_loc<=(Ndata/2+Nvc))))];

loc_Data=[2:2:2048];
loc_Data_outvc=loc_Data;
loc_Data_outvc(loc_Data_outvc==1)=[];
loc_Data_outvc(loc_Data_outvc>=(Ndata/2+2) & loc_Data_outvc<=(Ndata/2+Nvc))=[];

X_tx=zeros(1,Nfft);
        
X_tx(pilot_loc_outvc)=[X_pilot(Ndata/4+1:end) X_pilot(1:Ndata/4)];
X_tx(loc_Data_outvc)=[X_data_current(Ndata/4+1:end) X_data_current(1:Ndata/4)];



end