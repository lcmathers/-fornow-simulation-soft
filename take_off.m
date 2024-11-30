


function [mu_k,t_domain,delay_tap]= take_off(t_initial,num_points,fd,K_takeoff_1,f_los_takeoff,fs,delay_actual,delay_actual_dB,N,F,C)

%% 参数设定


%% 把T_sim改成想要生成的点数


Ts=1/fs; %采样周期



%% 指数衰减型功率谱的延时抽头生成
% max_delay=10e-6; % 最大时延
% edge_time=1e-6;  % 边沿时间
% N_delay=20; 
% [delay_actual,delay_tap,delay_dB]=delay_pdp1(N_delay,Ts,max_delay,edge_time);  % 注意：与采样周期匹配后，由于抽头的重复，抽头的数目可能变小

%% MMEA_SP 方法的参数生成

K=length(delay_actual); % 生成对应时延的数目
% [F,C,Th] = function_MMEA_SP_takeoff(N,K,fd,delay_actual_dB);

Th=rand(K,N)*2*pi;

%% 谐波叠加

fs1=fs; % 信道响应的抽样率
% fs1=100*max(max(F)); % 100倍的最大频率
%num_ponits=1e3;
%T_sim=num_ponits*Ts;


[mu_k,t_domain]=SOC_MMEA_SP(t_initial,F,C,Th,fs1,num_points,K_takeoff_1,f_los_takeoff);

% 时延抽头匹配
[delay_tap,mu_k]=delay_match(delay_actual,mu_k,Ts);

% %% 画出h(tau,t)
% [X,Y]=meshgrid(t_domain,delay_tap);
% figure;
% surf(X,Y*Ts,abs(mu_k));
% xlabel('time');
% ylabel('delay');
% zlabel('amplitude');
% 
% 
% %% 画出多普勒功率谱 和第一径相比较
% 
% S_theory=Doppler_spectrum(fd,1024);
% fdomain=linspace(0,fd,512);
% figure;
% plot(fdomain,S_theory(1:512));
% hold on;
% stem(F(1,:),C(1,:).^2/1e2);
% xlabel('frequency (Hz)');
% ylabel('Amplitude');
% 
% 
% %% 自相关函数的比较
% 
% delay_max=N/(2*fd); % 关心的最大时延
% %delay_max=0.1;
% Ns1=1e3;
% T1=delay_max/Ns1;
% delay_tau=[0:T1:(Ns1-1)*T1];
% angle_max=pi/2;
% N_angle=1000;
% angle=linspace(0,angle_max,N_angle);
% t1=0;
% h_theory=zeros(1,Ns1);
% h_model=zeros(K,Ns1);
% 
% 
% 
% % 理论自相关函数
% 
% for i=1:Ns1
%     AngleFunction=@(angle) exp(1j*(2*pi*fd*t1*cos(angle)));
%     h_theory(i) = 2/pi*integral(AngleFunction, 0, pi/2);
%     t1=t1+T1;
% end
% 
% % 时间遍历的自相关函数
% 
% t1=0;
% for i=1:Ns1
%     for k=1:K
%         h_model(k,i)=sum(exp(1j*2*pi*F(k,:)*t1)./N);
%     end
%     t1=t1+T1;
% end
% 
% % 时限（样本函数）的自相关函数 以第二径为列
% 
% % 计算数据的均值和标准差
% mu = mean(mu_k(2,:));
% sigma = std(mu_k(2,:));
% 
% % 对数据进行归一化处理
% normalized_data = (mu_k(2,:) - mu) / sigma;
% 
% [h_simulation,lags]=xcorr(normalized_data,'biased')  % biased estimator
% [h_simulation1,lags1]=xcorr(normalized_data,'unbiased')  % biased estimator
% lags=lags/fs1;
% lag_range = lags >= 0 & lags <= delay_max;
% acf_selected = h_simulation(lag_range);
% acf_selected1=h_simulation1(lag_range);
% lags_selected = lags(lag_range);
% 
% 
% 
% % 画出对比图
% figure;
% plot(delay_tau,abs(h_theory),'b-','LineWidth',1);
% hold on;
% plot(delay_tau,abs(h_model(1,:)),'k--','LineWidth',1);
% plot(lags_selected,abs(acf_selected),'m--','LineWidth',1);
% plot(lags_selected,abs(acf_selected1),'r--','LineWidth',1);
% xlabel('delay');
% ylabel('Amplitude');
% legend('theory','ergodic','time sampled BE','time sampled UE');
% 
% 
% % 概率分布
% figure;
% h=histogram(abs(mu_k(1,:)),'Normalization','pdf');
% xlabel('Amplitude');
% ylabel('Probability Density');
% title('PDF of the Amplitude of mu_k(1,:)');
% 
% figure;
% h1=histogram(abs(mu_k(2,:)),'Normalization','pdf');
% xlabel('Amplitude');
% ylabel('Probability Density');
% title('PDF of the Amplitude of mu_k(2,:)');

end