% simulate_pid_closed_loop.m
function [t, w, y, u] = simulate_pid_closed_loop(Kp, Ti, Td, a1, a2, b0, b1, d, Ts)
    
    % --- Casova os a Ziadana hodnota w ---
    % Simulacia trva napr. 10 sekund
    T_sim = 10; 
    N = round(T_sim / Ts);
    t = (0:N-1)' * Ts;
    
    % Navrh skokov ziadanej hodnoty (3V az 7V)
    w = zeros(N, 1);
    % Nastavte w[k] = 3V
    w(1:round(N/3)) = 3;
    % Skok na 7V
    w(round(N/3):round(2*N/3)) = 7; 
    % Skok naspat na 4V
    w(round(2*N/3):end) = 4;
    
    % --- Inicializacia ---
    y = zeros(N, 1);
    u = zeros(N, 1);
    e = zeros(N, 1); % Chyba
    
    % Diskrétne koeficienty PID
    % Clen I: akumulacia chyby
    I_sum = 0; 
    % Clen D: rozdiel chyby
    e_prev = 0; 
    
    % --- Simulacna slucka ---
    
    % Príprava vstupu motorčeka s oneskorením
    u_del = [zeros(d,1); u(:)]; 
    
    for k = 1:N
        % 1. Meranie chyby
        e(k) = w(k) - y(k);
        
        % 2. Vypocet I-clenu
        I_sum = I_sum + e(k);
        
        % 3. Vypocet D-clenu (diskretna diferencia)
        D_term = e(k) - e_prev;
        
        % 4. Vypocet riadiaceho signalu u[k] (pred saturaciou)
        % Ti musi byt nenulove, inak by I-clen isiel do nekonecna
        if Ti < 1e-6, I_contribution = 0; else I_contribution = (Ts / Ti) * I_sum; end
        
        u_calc = Kp * e(k) + Kp * I_contribution + Kp * (Td / Ts) * D_term;
        
        % 5. Saturacia u[k] (Akcny zasah v rozsahu 0-10V)
        u_sat = max(min(u_calc, 10), 0);
        u(k) = u_sat;
        
        % Anti-windup (iba pre cisty PID - ak chcete jednoduchy back-calculation, pridajte sem)
        % Napr.: I_sum = I_sum - (u_sat - u_calc) / (Kp * Ts/Ti); 
        
        % 6. Aktualizacia stavov regulátora
        e_prev = e(k);
        
        % 7. Simulacia motorceka (Model 2. radu ARX)
        % y[k] = -a1*y[k-1] - a2*y[k-2] + b0*u[k-d] + b1*u[k-1-d]
        
        yuk1 = 0; yuk2 = 0;
        if k-1 >= 1, yuk1 = y(k-1); end
        if k-2 >= 1, yuk2 = y(k-2); end
        
        % Oneskorenie vstupu
        idx_u = k - d;
        idx_u1 = k - d - 1;
        
        ukd = 0; uk1d = 0;
        
        if idx_u >= 1, ukd = u(idx_u); end
        if idx_u1 >= 1, uk1d = u(idx_u1); end
        
        % Aktualizacia vystupu motorceka (y[k])
        y_next = -a1*yuk1 - a2*yuk2 + b0*ukd + b1*uk1d;
        
        % Ulozenie vystupu (len ak to nie je posledna iteracia)
        if k < N 
            y(k+1) = y_next;
        end
    end
end