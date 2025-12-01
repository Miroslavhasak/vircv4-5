% simulate_model2.m
% diskretna ARX forma 2. radu:
% y[k] + a1*y[k-1] + a2*y[k-2] = b0*u[k-d] + b1*u[k-1-d]
% parametre: a1,a2,b0,b1,d, u
% ak b1==0 potom je to bez nuly

function yhat = simulate_model2(a1,a2,b0,b1,d,u)
    N = numel(u);
    yhat = zeros(N,1);
    u_del = [zeros(d,1); u(:)];
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
