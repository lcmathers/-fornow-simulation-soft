
function [y,h,t_final,mu_limited]=channel_SOS(x,channeltype,t_initial,fd,delay_actual,delay_actual_dB,F,C)

y=0; % receive signal

fs=20e6; % 采样频率
Ts=1/fs;
% fd=1000;

% fmin=250; % 巡航场景的fmin
% fmax=750; % 巡航场景的fmax

% max_delay=10e-6; % 最大时延
% edge_time=1e-6;  % 边沿时间
% N_delay=20;  % 时延抽头数目 
% 
% [delay_actual,delay_actual_dB]=delay_pdp1(N_delay,Ts,max_delay,edge_time);

K_takeoff=15;
K_takeoff_linear=10^(K_takeoff/10);

N=55; % number of sin
% t_initial=0;

num_points=length(x);


[mu_k_1,t_domain1,delay_tap1]= take_off(t_initial,num_points,fd,K_takeoff_linear,fd,fs,delay_actual,delay_actual_dB,N,F,C);

t_final=t_domain1(end);

[mu_limited,n1]=bandlimited_channel(mu_k_1,delay_tap1);

% 只保留延迟20个的抽头

n1=[-10:1:50];

% sum process

for i=1:length(n1)
    if n1(i)<0
        x_data=[x(-n1(i)+1:end) zeros(1,-n1(i))]
    else
        x_data=[zeros(1,n1(i)) x(1:end-n1(i))];
    end

    x_con=x_data.*mu_limited(n1(i)+101,:);

    y=y+x_con;

end

h=1;

end