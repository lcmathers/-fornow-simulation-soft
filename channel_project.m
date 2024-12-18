function [y,h]=channel_project(x,channeltype,fd,fmin,fmax)


%% 五个场景
%% 滑行       channeltype==1
%% 停泊       channeltype==2
%% 起飞/降落  channeltype==3
%% 巡航       channeltype==4
%% 飞过塔台

% clear channel;

fs=20e6; % 采样频率
% fs=1024*20*1e3;
Ts=1/fs;
% fd=4000;

% fmin=250; % 巡航场景的fmin
% fmax=750; % 巡航场景的fmax

max_delay=10e-6; % 最大时延
edge_time=1e-6;  % 边沿时间
N_delay=55;  % 时延抽头数目 

[delay_actual,delay_actual_dB]=delay_pdp1(N_delay,Ts,max_delay,edge_time);

delay_tap=floor(delay_actual./(Ts));

if channeltype==0

%% AWGN
    y=x;
    h=1;


elseif channeltype==1
%% Taxi 滑行场景

K_taxi=6.9;
K_taxi_linear=10^(K_taxi/10);

channel_taxi=comm.RicianChannel('SampleRate',fs,'PathDelays',delay_tap*Ts,'AveragePathGains',delay_actual_dB, ...
    'KFactor',K_taxi_linear,'MaximumDopplerShift',fd,'DirectPathDopplerShift',0.7*fd);

inf_taxi=info(channel_taxi);

y=channel_taxi(x')';
h=1;


elseif channeltype==2


%% Park 停泊场景



channel_park=comm.RayleighChannel('SampleRate',fs,'PathDelays',delay_tap*Ts,'AveragePathGains',delay_actual_dB, ...
    'MaximumDopplerShift',fd);

inf_park=info(channel_park);

y=channel_park(x')';
h=1;


elseif channeltype==3

%% takeoff 起飞降落场景

K_takeoff=15;
K_takeoff_linear=10^(K_takeoff/10);

s_takeoff=doppler('Asymmetric Jakes',[0,1]); % 半边Jakes谱

% s_takeoff=doppler('Jakes');


channel_takeoff=comm.RicianChannel('SampleRate',fs,'PathDelays',delay_tap*Ts,'AveragePathGains',delay_actual_dB, ...
    'DopplerSpectrum',s_takeoff,'MaximumDopplerShift',fd,'DirectPathDopplerShift',fd,'KFactor',K_takeoff_linear);

inf_takeoff = info(channel_takeoff);

y=channel_takeoff(x')';
h=1;

elseif channeltype==4

%% enroute 巡航场景

delay_enroute=[0 10]*1e-6;
delay_enroute_dB=[0 -30];

K_enroute=15;
K_enroute_linear=10^(K_enroute/10);

s_enroute=doppler('Asymmetric Jakes',[fmin/fd,fmax/fd]);

channel_enroute=comm.RicianChannel('SampleRate',fs,'PathDelays',delay_enroute,'AveragePathGains',delay_enroute_dB, ...
    'DopplerSpectrum',s_enroute,'MaximumDopplerShift',fd,'DirectPathDopplerShift',-fd,'KFactor',K_enroute_linear);

inf_enroute=info(channel_enroute);

y=channel_enroute(x')';
h=1;

end

end
