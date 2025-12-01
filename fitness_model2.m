% fitness_model2.m
% fitness pre model 2. radu v diferencnej forme
% parametre x = [a1, a2, b0, b1, d]
% rovnica: y[k] + a1*y[k-1] + a2*y[k-2] = b0*u[k-d] + b1*u[k-1-d]

function J = fitness_model2(x, u, y, Ts)
a1 = x(1); a2 = x(2); b0 = x(3); b1 = x(4); d = round(x(5));
N = numel(u);
yhat = zeros(N,1);
u_del = [zeros(d,1); u]; % posunuty vstup
% simuluj od k = 1 .. N (berieme y[-1],y[-2]=0)
for k = 1:N
yuk1 = 0; yuk2 = 0;
if k-1 >= 1, yuk1 = yhat(k-1); end
if k-2 >= 1, yuk2 = yhat(k-2); end
ukd = 0; uk1d = 0;
idx = k; % zatial index pre u_del (u_del ma d upfront zeros)
if idx <= numel(u_del), ukd = u_del(idx); end
if idx-1 >= 1 && idx-1 <= numel(u_del), uk1d = u_del(idx-1); end
yhat(k) = -a1*yuk1 - a2*yuk2 + b0*ukd + b1*uk1d;
end
e = y - yhat;
J = mean(e.^2);
if ~isfinite(J) || any(isnan(yhat))
J = 1e6;
end
end

% simulacne pomocne funkcie pre vykreslenie
function yhat = simulate_model2(a1,a2,b0,b1,d,u,~)
N = numel(u);
yhat = zeros(N,1);
u_del = [zeros(d,1); u];
for k = 1:N
yuk1 = 0; yuk2 = 0;
if k-1 >= 1, yuk1 = yhat(k-1); end
if k-2 >= 1, yuk2 = yhat(k-2); end
ukd = 0; uk1d = 0;
idx = k;
if idx <= numel(u_del), ukd = u_del(idx); end
if idx-1 >= 1 && idx-1 <= numel(u_del), uk1d = u_del(idx-1); end
yhat(k) = -a1*yuk1 - a2*yuk2 + b0*ukd + b1*uk1d;
end
end

function yhat = simulate_model1(K, T, d, u, Ts)
N = numel(u);
yhat = zeros(N,1);
alpha = exp(-Ts/T);
b0 = K*(1 - alpha);
a1 = alpha;
u_del = [zeros(d,1); u];
for k = 2:N
yhat(k) = a1*yhat(k-1) + b0*u_del(k);
end
end
