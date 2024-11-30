

function [f_result,C,Th] = function_MMEA_SP_takeoff(N,K,fd,delay_dB)

% N 谐波数
% K 实现个数
% fd 最大多普勒频偏


%% 一半的Jakes功率谱

% Define the Jakes power spectral density function
S = @(f, fd) (2 ./ (pi * fd * sqrt(1 - (f / fd).^2)));

% Define the integral function
f_integral = @(f, fd, C) integral(@(f_prime) S(f_prime, fd), 0, f) - C;


%% 计算频率参数
f_result=zeros(K,N);

for n=1:N
    for k=1:K

        C=(n-1/2)/N;
        rotation_k=(k-((K+1)/2))/(K*N);
        C=C+rotation_k;  % The desired integral result

        % Define the function to find the root 
        root_func = @(f) f_integral(f, fd, C);

        % Use fzero to find the root
        f_initial_guess = [0 fd]; % Initial guess for the root
        root = fzero(root_func, f_initial_guess);
        f_result(k,n)=root;

    end
end

% 参数c
C=zeros(K,N);
delay_linear=10.^(delay_dB/10);
C(:,:)=1/sqrt(N);
for i=1:K
    C(i,:)=C(i,:)*sqrt(delay_linear(i))
end

% 参数theta
Th=rand(K,N)*2*pi;

end