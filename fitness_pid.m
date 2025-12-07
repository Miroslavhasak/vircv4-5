% fitness_pid.m
function J = fitness_pid(x, a1, a2, b0, b1, d, Ts, lambda)
    Kp = x(1); Ti = x(2); Td = x(3);
    
    % Overenie platnosti parametrov (hlavne Ti)
    if Ti <= 1e-5
        J = 1e8; return; 
    end
    
    % Simulácia zatvorenej slučky
    [t, w, y, u] = simulate_pid_closed_loop(Kp, Ti, Td, a1, a2, b0, b1, d, Ts);
    
    % --- Vypocet Kriterialnej Funkcie J ---
    
    % 1. Regulačný výkon (ISE)
    e = w - y;
    ISE = sum(e.^2);
    
    % 2. Penalizacia Delta u
    delta_u = diff(u);
    penalty_delta_u = sum(delta_u.^2);
    
    % Celková kriteriálna funkcia
    J = ISE + lambda * penalty_delta_u;
    
    % Penalizacia pre nestabilne alebo zlyhavajuce simulacie (velmi vysoka chyba)
    if any(isnan(y)) || any(abs(y) > 20) || any(abs(u) > 10 + 1e-4) % Kontrola, ci vystup nevysiel mimo hranice
        J = 1e8; 
    end
end