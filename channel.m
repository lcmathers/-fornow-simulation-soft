function [y,h] = channel(x,channeltype)

% channeltype: 0 'AWGN'
% channeltype: 1 'fading'

if channeltype==0
    y=x;
    h=1;

elseif channeltype==1

    PowerdB=[0 -8 -17 -21 -25 ]; 
    Delay=[0 3 5 6 8 ];;   % Delay (Sample point)
    
    Power=10.^(PowerdB/10);
    Ntap=length(PowerdB);
    Lch=Delay(end)+1;

    channel=sqrt(Power/2).*(randn(1,Ntap)+1j*randn(1,Ntap));
    h=zeros(1,Lch);
    h(Delay+1)=channel;
    y=conv(x,h);

elseif channeltype==2

    fs=20e6;
    channel1=comm.RayleighChannel('SampleRate',fs,'AveragePathGains',[0 -8 -17 -21 -25],'PathDelays',[0 3 5 6 8]*(1/fs),'MaximumDopplerShift',1000);
    y=channel1(x')';
    h=1;

end

end