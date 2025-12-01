% simulate_model1.m
% diskretna simulacia 1. radu s dopravnym oneskorenim
% parametre: K, T, d (v pocte vzoriek), u, Ts

function yhat = simulate_model1(K, T, d, u, Ts)
    if nargin<5, error('simulate_model1: zly pocet argumentov'); end
    N = numel(u);
    yhat = zeros(N,1);
    if T <= 0
        yhat = zeros(N,1);
        return;
    end
    alpha = exp(-Ts / T); % diskretna konstanta
    b0 = K * (1 - alpha);
    u_del = [zeros(d,1); u(:)];
    for k = 2:N
        % index pre u_del je k (ma d nuly na zaciatku)
        idx = k;
        ud = 0;
        if idx <= numel(u_del), ud = u_del(idx); end
        yhat(k) = alpha * yhat(k-1) + b0 * ud;
    end
end
